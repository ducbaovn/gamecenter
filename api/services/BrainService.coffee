async = require('async')
_ = require('lodash')

fetchBrainConfig = (done)=>
  ConfigurationServive.getConfig Game.VISIBLE_APIS.BRAIN, (err, config) ->
    if err
      return done({code: 5000, error: err}, null)
    if !config?
      return done({code: 5029, error: "not found config"}, null)
    return done(null, config)


updatePlaying = (params, playingAttrs)=>
    # save log
  Game.findOne code: Game.VISIBLE_APIS.BRAIN, (err, game)->
    if err || !game
      return sails.log.info "[BrainService.updateScore] ERROR: Could not find Game... #{err}"
    
    logEinstein =
      user: params.user.id
      gameCode: game.code
      category: UserLog.CATEGORY.MONEY
      valueChange: playingAttrs.money
      reason: 'PLAY BRAIN SINGLE'
    UserLog.create logEinstein, (err, userLog)->
      if err
        sails.log.info "[BrainService.updateScore] ERROR: Could not log Einstein... #{err}"
    logTime =
      user: params.user.id
      gameCode: game.code
      category: UserLog.CATEGORY.TIME
      valueChange: parseInt(params.time) || 1
      reason: 'PLAY BRAIN SINGLE'
    UserLog.create logTime, (err, userLog)->
      if err
        sails.log.info "[BrainService.updateScore] ERROR: Could not log Time... #{err}"

    # update playing
    Playing.findOne {player: params.user.id, gameCode: game.code}, (err, playing)->
      if err
        sails.log.info "[BrainService.updateScore] ERROR: Could not get Playing... #{err}"

      if !playing?
        playingAttrs.gameCode = game.code
        playingAttrs.player = params.user.id

        Playing.create playingAttrs, (err, pl)->
          if err
            sails.log.info "[BrainService.updateScore] ERROR: Could not create Playing... #{err}"

      else
        playAttrs =
          # money: (playing.money || 0) + playingAttrs.money
          exp: (playing.exp || 0) + playingAttrs.exp
          cleverExp: (playing.cleverExp || 0) + playingAttrs.cleverExp
          exactExp: (playing.exactExp || 0) + playingAttrs.exactExp
          logicExp: (playing.logicExp || 0) + playingAttrs.logicExp
          naturalExp: (playing.naturalExp || 0) + playingAttrs.naturalExp
          socialExp: (playing.socialExp || 0) + playingAttrs.socialExp
          langExp: (playing.langExp || 0) + playingAttrs.langExp
          memoryExp: (playing.memoryExp || 0) + playingAttrs.memoryExp
          observationExp: (playing.observationExp || 0) + playingAttrs.observationExp
          judgementExp: (playing.judgementExp || 0) + playingAttrs.judgementExp

        Playing.update playing.id, playAttrs, (err, play)->
          if err
            sails.log.info "[BrainService.updateScore] ERROR: Could not update Playing... #{err}"

      # add money to user's bucket
      if game.moneyItem && playingAttrs.money
        BucketService.addItemToBucket
          itemid: game.moneyItem
          quantity: playingAttrs.money
          gameCode: game.code
          user: params.user
          reason: 'Thắng Game Đấu trí mode 1 người chơi'
        , (err, bucket)->
          if err
            sails.log.info err

updateUser = (params, playingAttrs)=>
  # update playing
  User.findOne {id: params.user.id}, (err, user)->
    if err
      sails.log.info "[BrainService.updateScore] ERROR: Could not get Playing... #{err}"

    userExp = (user.exp || 0) + playingAttrs.exp
    skillExp =
      cleverExp: (user.cleverExp || 0) + playingAttrs.cleverExp
      exactExp: (user.exactExp || 0) + playingAttrs.exactExp
      logicExp: (user.logicExp || 0) + playingAttrs.logicExp
      naturalExp: (user.naturalExp || 0) + playingAttrs.naturalExp
      socialExp: (user.socialExp || 0) + playingAttrs.socialExp
      langExp: (user.langExp || 0) + playingAttrs.langExp
      memoryExp: (user.memoryExp || 0) + playingAttrs.memoryExp
      observationExp: (user.observationExp || 0) + playingAttrs.observationExp
      judgementExp: (user.judgementExp || 0) + playingAttrs.judgementExp
    
    LevelService.getUserLevel userExp, (err, userLevel)->
      if err
        return sails.log.info "[BrainService] ERROR: Could not get User Level... #{err}"
      exp_lvl = {}
      async.each skillExp, (exp, cb)->
        LevelService.getSkillLevel exp, (err, skillLevel)->
          if err
            return cb("[BrainService] ERROR: Could not get User Level... #{err}")
          exp_lvl[exp] = skillLevel
          return cb()
      , (err)->
        if err
          return sails.log.info err
        userAttrs = skillExp
        userAttrs.exp = userExp
        userAttrs.level = userLevel
        userAttrs.cleverLvl = exp_lvl[cleverExp]
        userAttrs.exactLvl = exp_lvl[exactExp]
        userAttrs.logicLvl = exp_lvl[logicExp]
        userAttrs.naturalLvl = exp_lvl[naturalExp]
        userAttrs.socialLvl = exp_lvl[socialExp]
        userAttrs.langLvl = exp_lvl[langExp]
        userAttrs.memoryLvl = exp_lvl[memoryExp]
        userAttrs.observationLvl = exp_lvl[observationExp]
        userAttrs.judgementLvl = exp_lvl[judgementExp]
  
        User.update user.id, userAttrs, (err, user)->
          if err
            sails.log.info "[BrainService] ERROR: Could not update User... #{err}"

calcEinsteinMoney = (params, conf, done)=>
  einsteinRandomFactor = _.random(conf.minEinsteinRandomFactor, conf.maxEinsteinRandomFactor)
  # moneyForLevel = Math.ceil((user.level * einsteinRandomFactor + user.level) / (time/1000) * conf.einsteinRate)
  cleverExp = (params.correct + params.wrong) / (params.time * 1.5)
  exactExp = (params.correct - params.wrong) / (params.correct + params.wrong)
  judgementExp = (params.correct - params.wrong) / params.time
  logicExp = (params.correct / params.time + exactExp) / 2
  memoryExp = (1.5 * params.correct / params.time + exactExp) / 2.5
  observationExp = (params.correct / params.time + 1.5*exactExp) / 2.5

  # naturalExp = conf[params.miniGameCode].naturalExp
  # socialExp = conf[params.miniGameCode].socialExp
  # langExp = conf[params.miniGameCode].langExp

  playingAttrs =
    exp: conf.exp
    # money: moneyForLevel
    cleverExp: cleverExp
    exactExp: exactExp
    judgementExp: judgementExp 
    logicExp: logicExp
    memoryExp: memoryExp
    observationExp: observationExp
    # naturalExp: naturalExp
    # socialExp: socialExp
    # langExp: langExp

  updatePlaying(params, playingAttrs)
  updateUser(params, playingAttrs)
  return done(null, playingAttrs)


calcToUpdateUser = (params, done)=>
  fetchBrainConfig params.miniGameCode, (err, conf)->
    if err
      return done(err)

    calcEinsteinMoney(params, conf, done)


exports.updateScore = (params, done)=>
  calcToUpdateUser params, (err, playingAttrs)->
    if err
      return done(err, null)
    return done(null, playingAttrs)