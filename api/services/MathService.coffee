async = require('async')
_ = require('lodash')

fetchMathConfig = (mode, done)=>
  ConfigurationServive.getConfig Game.VISIBLE_APIS.MATH, (err, config) ->
    if err
      return done({code: 5000, error: err}, null)
    if !config?
      return done({code: 5029, error: "not found config"}, null)
    return done(null, config[mode])


updateMathPlaying = (req, data)=>
  Game.findOne {code: Game.VISIBLE_APIS.MATH}
  .exec (err, game)->
    if err
      sails.log.info err
      return false
    if ! game?
      sails.log.info "not found #{Game.VISIBLE_APIS.MATH}"
      return false

    # save log
    logEinstein =
      user: req.user
      gameCode: game.code
      category: UserLog.CATEGORY.MONEY
      valueChange: data.money
      reason: 'PLAY MATH SINGLE'
    UserLog.create logEinstein, (e, userLog)->
      if e
        return done(e, null)

    logTime =
      user: req.user
      gameCode: game.code
      category: UserLog.CATEGORY.TIME
      valueChange: data.time
      reason: 'PLAY MATH SINGLE'
    UserLog.create logTime, (e, userLog)->
      if e
        return done(e, null)

    # update playing
    Playing.findOne {player: req.user.id, gameCode: game.code}, (e, playing)->
      if e
        sails.log.info e
        return

      if ! playing?
        data.gameCode = game.code
        data.player = req.user.id

        Playing.create data, (ex, pl)->
          sails.log.info ex
          sails.log.info pl

      else
        playAttrs =
          exp: (playing.exp || 0)+ data.exp         
          cleverExp: (playing.cleverExp || 0)+ data.cleverExp 
          exactExp: (playing.exactExp || 0)+ data.exactExp 
          logicExp: (playing.logicExp || 0)+ data.logicExp 
          naturalExp: (playing.naturalExp || 0)+ data.naturalExp 
          socialExp: (playing.socialExp || 0)+ data.socialExp 
          langExp: (playing.langExp || 0)+ data.langExp 
          memoryExp: (playing.memoryExp || 0)+ data.memoryExp 
          observationExp: (playing.observationExp || 0)+ data.observationExp 
          judgementExp: (playing.judgementExp || 0)+ data.judgementExp 

        Playing.update playing.id, playAttrs, (er, play)->
          if er
            sails.log.error er
            sails.log.info 'could not update playing'

      # add money to user's bucket
      if game.moneyItem
        BucketService.addItemToBucket 
          gameCode: game.code
          itemid: game.moneyItem
          quantity: data.money
          game: game
          user: req.user
          reason: 'Thắng mode 1 người chơi'
        , (e, bucket)->
          if e
            sails.log.info e


calcEinsteinMoney = (req, conf, done)=>
  user = req.user
  time = parseInt(req.param('time') || 1)

  einsteinRandomFactor = _.random(conf.minEinsteinRandomFactor, conf.maxEinsteinRandomFactor)
  moneyForLevel = Math.ceil((user.level * einsteinRandomFactor + user.level) / (time/1000) * conf.einsteinRate)

  playingAttrs = 
    time: time
    gameCode: Game.VISIBLE_APIS.MATH
    exp: 0
    money: moneyForLevel
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    memoryExp: 0
    observationExp: 0
    judgementExp: 0

  updateMathPlaying(req, playingAttrs)
  return done(null, playingAttrs)


calcToUpdateUser = (req, done)=>
  fetchMathConfig req.param('mode'), (e, conf)->
    if e
      return done(e)

    calcEinsteinMoney(req, conf, done)    


exports.updateScore = (req, done)=>
  data = 
    mode: req.param('mode')
    operator: req.param('operator')
    time: parseInt(req.param('time') || 0)
    user: req.user.id

  MathScore.findOne {mode: data.mode, operator: data.operator, user: data.user}, (err, score)->
    if err
      return done({code: 5000, error: err}, null)
    if !score?
      return MathScore.create data, (e, sc)->
        if e
          return done({code: 5000, error: e}, null)
        if !sc 
          return done({code: 5028, error: "could not create score"}, null)

        # update user exp
        return calcToUpdateUser req, (e, result)->
          if e
            return done(e, null)
          result = _.merge(sc, result)
          return done(null, result)

    if score.time <= data.time
      return calcToUpdateUser req, (e, result)->
        if e
          return done(e, null)
        result = _.merge(score, result)
        return done(null, result)

    MathScore.update score.id, data, (e, scr)->
      if e
        sails.log.info e
        return done({code: 5000, error: e}, null)

      return calcToUpdateUser req, (e, result)->
        if e
          return done(e, null)
        result = _.merge(scr[0], result)
        return done(null, result)


exports.myInfo = (req, done)=>  
  findLevel = (lv, cb)->
    Level.findOne name: lv, (e, level)->
      if e
        return cb({code: 5000, error: e}, null)
      if ! level? 
        return cb(null, {})
      return cb(null, level)

  findPlaying = (player, cb)->
    Playing.findOne {player: player, gameCode: Game.VISIBLE_APIS.MATH}, (er, playing)->
      if er
        return cb({code: 5000, error: er}, null)
      if ! playing?
        return cb(null, null)
      return cb(null, playing)

  nextLevel = (req.user.level || 0) + 1
  async.parallel
    level: (cb)-> findLevel(nextLevel, cb)
    playing: (cb)-> findPlaying(req.user.id, cb)
  , (err, result)->
    if err
      return done(err, null)

    rt = UserService.myAttrs(req.user)

    rt.einstein = 0
    rt.levelExp = 0

    if result.level?
      rt.levelExp = result.level.exp
    if result.playing?
      rt.einstein = result.playing.money
    done(null, rt)






