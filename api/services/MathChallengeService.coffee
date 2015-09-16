_ = require('lodash')
async = require('async')
require('date-utils')

ObjectId = require('mongodb').ObjectID

verifyChallenge = (params)=>
  if !params.scoreid || !params.times || !params.money || !params.target || params.times > 100 || params.days > 100
    return false
  return true  

challengeCost = (params)=>
  costStars = 0
  if params.target == Challenge.TARGETS.FRIEND
    costStars = Math.ceil((params.times * params.money) * (1 + Challenge.FRIEND_COST))
  else
    costStars = Math.ceil((params.times * params.money) * (1 + Challenge.WORLD_COST))
  return costStars


# TODO
# move this heavy task to queue or another server
sendNotificationAddChallenge = (params)->
  fetchFriendIds = (userId, cb)->
    # TODO
    # get user fiends    
    User.find {id: '!': userId}, (e, rsts)->    
      if e
        return cb(e, null)      
      ids = _.pluck(rsts, 'id')
      return cb(null, ids)

  fetchFriendIds params.user.id, (e, userIds)->
    _.each userIds, (userId)->
      NotificationService.getConfig {user: userId, category: NoteMessage.NOTIFY_CATEGORIES.CHALLENGE}, (isActive)->
        if isActive
          notification = 
            user: userId
            gameCode: params.game.code
            category: NoteMessage.NOTIFY_CATEGORIES.CHALLENGE
            title: params.message.title
            content: params.message.content
            imageUrl: params.game.icon
            extends: 
              gameCode: params.game.code
              gamename: params.game.name
              packageIdIos: params.game.packageId.ios
              packageIdAndroid: params.game.packageId.android
              challengeId: params.challenge.id
              moneyPerOne: params.challenge.moneyPerOne

          NotificationService.createNotification notification, (e, note)->            
            sails.log.info e if e


exports.addChallenge = (req, resp)=>
  params = 
    scoreid: req.param('scoreid')
    times: req.param('times')
    money: req.param('money')
    target: req.param('target')
    days: req.param('days')
    
  today = new Date()
  if !verifyChallenge(params)
    return resp.status(400).send({code: 5031, error: 'invalid params'})

  MoneyService.verifyStarMoney req.user, challengeCost(params), (isEnough)->
    if !isEnough
      return resp.status(400).send({code: 5026, error: 'not enough stars'})

    MathScore.findOne params.scoreid, (err, score)->
      if err
        return resp.status(400).send({code: 5000, error: err})
      if !score?
        return resp.status(400).send({code: 5032, error: "score is invalid"})
      
      ####### TODO
      ###### VALIDATION USER MONEY
      Game.findOne { code: Game.VISIBLE_APIS.MATH }, (e, game)->
        if e
          return resp.status(400).send({code: 5000, error: e})
        if !game
          return resp.status(400).send({code: 5033, error: "could not found game"})
        
        days = parseInt(req.param('days') || 1)

        challengeData = 
          gameCode: game.code
          user: req.user.id
          imageUrl: game.icon
          availTimes: params.times
          moneyPerOne: params.money
          expiredAt: today.addDays(days)
          target: params.target
          actionParams:
            gamecode: game.code
            gamename: game.name            
            packageIdIos: game.packageId.ios
            packageIdAndroid: game.packageId.android

        mathChallengeData = 
          challenge: challengeData
          mode: score.mode
          operator: score.operator
          time: score.time

        MessageService.Math.getChallengeMessage mathChallengeData, req.user, (message)->
          challengeData.title = message.title
          challengeData.content = message.content

          Challenge.create challengeData, (e, cl)->
            if e
              sails.log.error "ERROR: ... #{JSON.stringify(e)}"
              return resp.status(400).send({code: 5000, error: e})

            if !cl?
              sails.log.error "ERROR: ... #{JSON.stringify(e)}"
              return resp.status(400).send({code: 5034, error: "could not create challenge"})

            mathChallengeData.challenge = cl.id

            MathChallenge.create mathChallengeData, (e, mcl)->
              if e
                sails.log.error "ERROR: ... #{JSON.stringify(e)}"
                return resp.status(400).send({code: 5000, error: e})

              if ! mcl?
                Challenge.destroy {id: cl.id}
                sails.log.error "ERROR: ... #{JSON.stringify(e)}"
                return resp.status(400).send({code: 5035, error: "could not create math challenge"})

              cl.actionParams.challengeId = cl.id
              cl.save()

              # desc user money
              # TODO
              # add params.project            
              params =
                star: cl.costAmount()
                itemid: cl.id
                note: "Tạo thách thức"
                gameCode: game.code
              MoneyService.descStars req.user, params, (e)->
                sails.log.info e

              mcl = _.merge(mcl, cl)
              delete mcl.challenge

              # send notification
              sendNotificationAddChallenge {
                user: req.user
                message: message
                gameCode: game.code
                challenge: cl
              }

              # TODO
              # refund deposit money when challenge is expired               
              jobFunc = () ->
                cl.destroy()
                MathChallenge.destroy challenge: cl.id
              TimeJobService.queue(challengeData.expiredAt, jobFunc)

              return resp.status(200).send(mcl)


exports.stopChallenge = (req, resp)=>
  Challenge.findOne {id: req.param('id')}
  .exec (err, challenge)->
    if err
      return resp.status(400).send({code: 5000, error: err})
    if ! challenge?
      return resp.status(400).send({code: 5036, error: 'not found the challenge'})

    if challenge.user != req.user.id
      return resp.status(400).send({code: 5037, error: 'you are not the challenge owner'})
    game = challenge.game
    User.findOne {id: challenge.user}, (er, owner)->      
      if er
        return resp.status(400).send({code: 5000, error: er})
      if ! owner?
        return resp.status(400).send({code: 5038, error: 'not found challenge owner'})
      
      remainingMoney = challenge.remainingMoney()
      if challenge.isHolding
        return resp.status(400).send({code: 5039, error: 'this challenge is holding'})
      
      challenge.destroy (e,x)->
        if e
          return resp.status(400).send({code: 5000, error: e})

        MathChallenge.destroy {challenge: challenge.id}, (e, r)->
          if e
            return resp.status(400).send({code: 5000, error: e})

          # TODO log user balance
          # add params.project
          if remainingMoney > 0
            params = 
              star: remainingMoney              
              itemid: challenge.id
              note: "Hủy thách thức"
              gameCode: game.code
            MoneyService.incStars owner, params, (ee)->
              sails.log.info ee
          return resp.status(200).send(success: 'ok')


exports.myChallenges = (req, done)=>

  params = req.allParams()
  params.user = req.user
  params.gamecode = Game.VISIBLE_APIS.MATH

  ChallengeService.myChallenges params, (e, challenges)->
    if e
      return done(e, null)

    buildMathChalllenge = (challenge, cb)->  
      MathChallenge.findOne {challenge: challenge.id}, (e, mcl)->                
        if e
          return cb({code: 5000, error: e},null)
        if !mcl
          return cb({code: 5040, error: "could not found math challenge"}, null) 

        challenge.mode = mcl.mode
        challenge.operator = mcl.operator
        challenge.time = mcl.time

        return cb(null, challenge)

    async.map challenges, buildMathChalllenge, (e, result)->
      if e
        return done({code: 5000, error: 'cannot get results'}, null)

      return done(null, result)


exports.suggestChallenges = (req, done)=>
  
  params = req.allParams()
  params.user = req.user
  params.gamecode = Game.VISIBLE_APIS.MATH

  ChallengeService.suggestChallenges params, (e, challenges)->
    if e
      return done(e, null)

    buildMathChalllenge = (challenge, cb)->      
      MathChallenge.findOne {challenge: challenge.id}, (e, mcl)->
        if e
          return cb({code: 5000, error: e},null)
        if !mcl
          return cb({code: 5040, error: "could not found math challenge"}, null) 

        challenge.mode = mcl.mode
        challenge.operator = mcl.operator
        challenge.time = mcl.time

        challenge.remainingTimes = challenge.remainingTimes()
        challenge.user =
          id: challenge.user.id
          fullname: challenge.user.fullname
          nickname: challenge.user.nickname
          avatar_url: challenge.user.avatar_url
          gender: challenge.user.gender
          dob: challenge.user.dob
          level: (challenge.user.level || 1)
          
        delete challenge.isHolding
        delete challenge.playsCount
        delete challenge.availTimes
        delete challenge.failuresCount

        return cb(null, challenge)

    async.map challenges, buildMathChalllenge, (e, result)->
      if e
        return done({code: 5000, error: 'cannot get results'}, null)

      return done(null, result)
  

exports.acceptChallenge = (req, resp)=>
  challengeid = req.param('challengeid')

  if LockerService.isLocked challengeid
    return resp.status(400).send({code: 5039, error: 'this challenge is holding'})

  # lock this operation
  LockerService.lock challengeid

  # check the challenge
  user = req.user
  query = 
    id: challengeid
    user: {'!': req.user.id}

  Challenge.findOne query, (err, challenge)->      
    if err
      LockerService.unlock challengeid
      return resp.status(400).send({code: 5000, error: err})
    if ! challenge?
      LockerService.unlock challengeid
      return resp.status(400).send({code: 5036, error: 'not found challenge'})
    if challenge.isHolding
      LockerService.unlock challengeid
      return resp.status(400).send({code: 5039, error: 'this challenge is holding'})
    if challenge.remainingTimes == 0
      LockerService.unlock challengeid
      return resp.status(400).send({code: 5041, error: 'challenge is not available'})

    # verify user money
    MoneyService.verifyStarMoney user, challenge.moneyPerOne, (isEnough)->
      if ! isEnough
        LockerService.unlock challengeid
        return resp.status(400).send({code: 5026, error: 'not enough money'})

      timeNow = new Date()
      acceptData = 
        user: user.id
        mathchallenge: challenge.id
        status: MathMatch.STATUSES.PLAYING
        expiredAt: timeNow.addSeconds(MathMatch.EXPIRED_IN_SECONDS+5)
      MathMatch.create acceptData, (e, acceptance)->
        if e
          LockerService.unlock challengeid
          return resp.status(400).send({code: 5000, error: e})
        if !acceptance
          LockerService.unlock challengeid
          return resp.status(400).send({code: 5042, error: 'could not accept the challenge'})

        # TODO need add 
        # params.project
        params =
          star: challenge.moneyPerOne
          itemid: challenge.id
          note: "Chấp nhận thách thức"
          game: challenge.game
        MoneyService.descStars user, params, (e, usr)->
          if e
            acceptance.destroy()
            LockerService.unlock challengeid
            return resp.status(400).send(e)

          challenge.playsCount = (challenge.playsCount||0) + 1
          challenge.isHolding = true
          challenge.save (e)->
            if e
              LockerService.unlock challengeid
              return resp.status(400).send({code: 5000, error: e})

            LockerService.unlock challengeid
            return resp.status(200).send(acceptance)