_ = require('lodash')
async = require('async')
ObjectId = require('mongodb').ObjectID
require('date-utils')

sendNotificationAddChallenge = (params)->
  _.each params.noteUsers, (userId)->
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

        NotificationService.createNotification notification, (err, note)->
          sails.log.info err.log if err

exports.add = (params, done)->
  if !params.availTimes || !params.expiredAt || !params.moneyPerOne || !params.score || !params.type
    return done({code: 6067, error: 'Missing params', log: "[ChallengeService.add] ERROR: Missing params"})
  if params.type not in _.values(Challenge.TYPE)
    params.type = Challenge.TYPE.WORLD
  if params.type == Challenge.TYPE.OPTION && !params.target
    return done({code: 6067, error: 'Missing params', log: "[ChallengeService.add] ERROR: Missing params"})
  challengeCost = params.availTimes * params.moneyPerOne
  MoneyService.verifyStarMoney params.user, challengeCost, (isEnough)->
    if !isEnough
      return done({code: 6070, error: 'Not enough stars', log: "[ChallengeService.add] ERROR: Not enough stars to add challenge"})

    Score.findOne id: params.score, (err, score)->
      if err || !score
        return done({code: 6066, error: 'Invalid score', log: "[ChallengeService.add] ERROR: Invalid score"})
      params.gameCode = score.gameCode
      params.user = score.user
      
      switch params.gameCode
        when Game.VISIBLE_APIS.TTT01
          Game.findOne code: score.gameCode, (err, game)->
            if err || !game
              return done({code: 6066, error: 'Invalid game code', log: "[ChallengeService.add] ERROR: Invalid game code"})
          params.imageUrl = game.icon

          Challenge.create params, (err, challenge)->
            if err
              return done({code: 5000, error: 'Could not process', log: "[ChallengeService.add] ERROR: Could not process - create Challenge... #{err}"})
            costData =
              star: challengeCost
              itemid: challenge.id
              note: 'Tạo thách thức'
            MoneyService.descStars params.user, costData, (err, user)->
              if err
                return done(err, null)
              return done(null, {challenge: challenge, user: user})

            if params.noteUsers
              challenge.score = score
              MessageService.Math.getChallengeMessage challenge, req.user, (message)->
                sendNotificationAddChallenge
                  noteUsers: params.noteUsers
                  message: message
                  game: game
                  challenge: challenge
        
        when Game.VISIBLE_APIS.BRAIN
          Game.findOne code: params.gameCode, (err, game)->
            if err || !game
              return done({code: 6066, error: 'Invalid game code', log: "[ChallengeService.add] ERROR: Invalid game code"})
            Game.findOne code: score.info.miniGame, (err, minigame)->
              if err || !minigame
                return done({code: 6066, error: 'Invalid game code', log: "[ChallengeService.add] ERROR: Invalid game code"})
            params.imageUrl = minigame.icon
            
            Challenge.create params, (err, challenge)->
              if err
                return done({code: 5000, error: 'Could not process', log: "[ChallengeService.add] ERROR: Could not process - create Challenge... #{err}"})
              costData =
                star: challengeCost
                itemid: challenge.id
                note: 'Tạo thách thức'
              MoneyService.descStars params.user, costData, (err, user)->
                if err
                  return done(err, null)
                return done(null, {challenge: challenge, user: user})

              if params.noteUsers
                challenge.score = score
                MessageService.Brain.getChallengeMessage challenge, req.user, (message)->
                  sendNotificationAddChallenge
                    noteUsers: params.noteUsers
                    message: message
                    game: game
                    challenge: challenge
        
# exports.remove = (params, done)->
#   if !params.id
#     return done({code: 6074, error: "Missing params id", log: "[ChallengeService.remove] ERROR: Missing params id"})
#   Challenge.destroy id: params.id, (err, ok)->
#     if err
#       return done({code: 5000, error: "Could not process", log: "[ChallengeService.remove] ERROR: Could not process - destroy Challenge... #{err}"})
#     return done(null, {success: 'Remove Score successful.'})

exports.get = (params, done)->
  Challenge.findOne {id: params.challengeId}, (err, challenge)->
    if err
      return done({code: 5000, error: 'Could not process', log: "[ChallengeService.get] ERROR: Could not process - get Challenge... #{err}"})
    if !challenge
      return done({code: 6066, error: 'Invalid challengeId', log: "[ChallengeService.get] ERROR: Invalid challengeId"})

    return done(null, challenge)

exports.myChallenges = (params, done)->
  page = parseInt(params.page) || 1
  limit = parseInt(params.limit) || 10
  skip = page * limit

  Challenge.native (err, collection)->
    if err
      return done({code: 5000, error: 'Could not process', log: "[ChallengeService.myChallenges] ERROR: Could not process - native Challenge... #{err}"})
    cond =
      expiredAt: {$gt: (new Date())}
      user: ObjectId(params.user.id)
      $where: "this.availTimes > this.failuresCount"
    if params.gameCode
      cond.gameCode = params.gameCode
    
    sortCond = {}
    if !params.sortBy || params.sortBy not in ['gameCode', 'moneyPerOne', 'expiredAt']
      params.sortBy = 'updatedAt'
    if !params.sortOrder || params.sortOrder not in [-1, 1]
      params.sortOrder = -1
    sortCond[params.sortBy] = params.sortOrder

    query = collection.find cond,
      id: true
      gameCode: true
      user: true
      imageUrl: true
      isHolding: true
      availTimes: true
      playsCount: true
      failuresCount: true
      expiredAt: true
      moneyPerOne: true
      target: true
      scoreInfo: true
    .sort(sortCond)
    
    if limit > 0
      query = query.skip(skip).limit(limit)

    query.toArray (err, result)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.myChallenges] ERROR: Could not process - get Challenge... #{err}"})

      async.map result, (challenge, cb)->  
        challenge.id = challenge._id.toString()
        delete challenge._id
        return cb(null, challenge)
      , (err, list)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.myChallenges] ERROR: Could not process... #{err}"})
        collection.count cond, (err, total)->
          if err
            return done({code: 5000, error: 'Could not process', log: "[ChallengeService.myChallenges] ERROR: Could not process - count Challenge... #{err}"})
        
          return done(null, {result: list, total: total})

exports.friendList = (params, done)->
  page = parseInt(params.page) || 1
  limit = parseInt(params.limit) || 10
  skip = page*limit
  if !params.sortBy || params.sortBy not in ['expiredAt', 'gameCode', 'moneyPerOne']
    params.sortBy = 'updatedAt'
  if !params.sortOrder || params.sortOrder not in ['desc', 'asc']
    params.sortOrder = 'desc'
  if !params.user
    return done({code: 6067, error: 'Missing params user', log: "[ChallengeService.list] ERROR: Missing params user"})

  fetchFriendIds = (userId, done)->
    # TODO
    # get user fiends
    # friends = []
    # Friend.findOne user: userId, friend: true, (e, result1)->
      # if err
      #   return done({code: 5000, error: err}, null)
      # friends = _.pluck(result1, 'friend')
      # Friend.findOne friend: userId, user: true, (e, result2)->
      #   if err
      #     return done({code: 5000, error: err}, null)
      #   friends.concat(_.pluck(result2, 'user')
      #   return done(null, result.friends)
    return done(null, [])

  friendWorldChallenges = (friends, done)->
    if friends[0]?
      return done(null, [])
    cond =
      user: {$in: friends}
      target: {$ne: Challenge.TYPE.OPTION}
      expiredAt: {$gt: (new Date())}
      $where: "this.availTimes > this.failuresCount"

    if params.gameCode
      cond.gameCode = params.gameCode
      
    Challenge.native (err, collection)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - native Challenge... #{err}"})

      collection.find cond
      .toArray (err, result)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
        return done(null, _.pluck(result, '_id'))

  optionChallenges = (userId, friends, done)->
    if friends.length == 0
      return done(null, [])
    User.findOne id: userId
    .populate 'targetedChallenge'
    .exec (err, user)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get User... #{err}"})
      optionChallenge = _pluck(user.targetedChallenge, 'id')
      Challenge.native (err, collection)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - native Challenge... #{err}"})
        cond =
          id: {$in: optionChallenge}
          user: {$in: friends}
          target: Challenge.TYPE.OPTION
          expiredAt: {$gt: (new Date())}
          $where: "this.availTimes > this.failuresCount"
        if params.gameCode
          cond.gameCode = params.gameCode

        collection.find cond, id: true
        .toArray (err, friendOptions)->
          if err
            return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
          return done(null, friendOptions)

  fetchFriendIds params.user.id, (err, friends)->
    async.parallel [
      (cb)-> friendWorldChallenges(friends, cb)
      (cb)-> optionChallenges(params.user.id, friends, cb)
    ], (err, result)->
      if err
        return done(err)
      cond = id: result[0].concat(result[1])
      if limit > 0
        cond.limit = limit
        cond.skip = skip
      sortCond = {}
      sortCond[params.sortBy] = params.sortOrder

      Challenge.find cond
      .populate('user')
      .sort(sortCond)
      .exec (err, list)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
        return done(null, {result: list, total: cond.id.length})

exports.worldList = (params, done)->
  page = parseInt(params.page) || 1
  limit = parseInt(params.limit) || 10
  skip = page*limit
  if !params.sortBy || params.sortBy not in ['expiredAt', 'gameCode', 'moneyPerOne']
    params.sortBy = 'updatedAt'
  if !params.sortOrder || params.sortOrder not in ['desc', 'asc']
    params.sortOrder = 'desc'
  if !params.user
    return done({code: 6067, error: 'Missing params user', log: "[ChallengeService.list] ERROR: Missing params user"})

  fetchFriendIds = (userId, done)->
    # TODO
    # get user fiends
    # friends = []
    # Friend.findOne user: userId, friend: true, (e, result1)->
      # if err
      #   return done({code: 5000, error: err}, null)
      # friends = _.pluck(result1, 'friend')
      # Friend.findOne friend: userId, user: true, (e, result2)->
      #   if err
      #     return done({code: 5000, error: err}, null)
      #   friends.concat(_.pluck(result2, 'user')
      #   return done(null, result.friends)
    return done(null, [])

  friendChallenges = (friends, done)->
    if friends[0]?
      return done(null, [])
    cond =
      target: Challenge.TARGETS.FRIEND
      expiredAt: {$gt: (new Date())}
      $where: "this.availTimes > this.failuresCount"

    if params.gameCode
      cond.gameCode = params.gameCode
      
    Challenge.native (err, collection)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - native Challenge... #{err}"})

      collection.find cond, id: true
      .toArray (err, result)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
        return done(null, result)

  worldChallenges = (userId, done)->
    # TODO
    # get avail cl for user
    cond =
      user: {$ne: ObjectId(userId)}
      target: Challenge.TARGETS.WORLD
      expiredAt: {$gt: (new Date())}
      $where: "this.availTimes > this.failuresCount"

    if params.gameCode
      cond.gameCode = params.gameCode
      
    Challenge.native (err, collection)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - native Challenge... #{err}"})

      collection.find cond, id: true
      .toArray (err, result)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
        return done(null, result)

  optionChallenges = (userId, done)->
    User.findOne id: userId
    .populate 'targetedChallenge'
    .exec (err, user)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get User... #{err}"})
      optionChallenge = user.targetedChallenge

      Challenge.native (err, collection)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - native Challenge... #{err}"})
        cond =
          id: {$in: optionChallenge}
          expiredAt: {$gt: (new Date())}
          $where: "this.availTimes > this.failuresCount"
        if params.gameCode
          cond.gameCode = params.gameCode

        collection.find cond, id: true
        .toArray (err, result)->
          if err
            return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
          return done(null, result)

  fetchFriendIds params.user.id, (err, friends)->
    async.parallel [
      (cb)-> friendChallenges(friends, cb)
      (cb)-> worldChallenges(params.user.id, cb)
      (cb)-> optionChallenges(params.user.id, cb)
    ], (err, result)->
      if err
        return done(err)
      cond = id: result[0].concat(result[1]).concat(result[2])
      if limit > 0
        cond.limit = limit
        cond.skip = skip
      sortCond = {}
      sortCond[params.sortBy] = params.sortOrder

      Challenge.find cond
      .populate('user')
      .sort(sortCond)
      .exec (err, list)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.list] ERROR: Could not process - get Challenge... #{err}"})
        return done(null, {result: list, total: cond.id.length})

exports.accept = (params, done)->
  if LockerService.isLocked params.challengeId
    return done({code: 6069, error: 'This challenge is holding', log: "[ChallengeService.accept] ERROR: This challenge is holding"})

  # lock this operation
  LockerService.lock params.challengeId

  # check the challenge
  query = 
    id: params.challengeId
    user: {'!': params.user.id}

  Challenge.findOne query
  .populate 'score'
  .exec (err, challenge)->      
    if err || !challenge
      LockerService.unlock params.challengeId
      return done({code: 5000, error: 'Could not process', log: "[ChallengeService.accept] ERROR: Could not process - get Challenge... #{err}"})

    if challenge.remainingTimes == 0
      LockerService.unlock params.challengeId
      return done({code: 6070, error: 'Challenge is not available', log: "[ChallengeService.accept] ERROR: This challenge is not available"})
    timeNow = new Date()
    if timeNow > challenge.expiredAt
      LockerService.unlock params.challengeId
      return done({code: 6071, error: 'Challenge is expired', log: "[ChallengeService.accept] ERROR: This challenge is expired"})
      
    # verify user money
    MoneyService.verifyStarMoney user, challenge.moneyPerOne, (isEnough)->
      if !isEnough
        LockerService.unlock params.challengeId
        return done({code: 6072, error: 'Not enough money', log: "[ChallengeService.accept] ERROR: Not enough money"})

      acceptData = 
        user: params.user.id
        challenge: challenge.id
        status: ChallengeMatch.STATUSES.PLAYING
        expiredAt: timeNow.addMilliseconds(challenge.score.time + 5000)
      ChallengeMatch.create acceptData, (err, acceptance)->
        if err || !acceptance
          LockerService.unlock params.challengeId
          return done({code: 5000, error: 'Could not process', log: "[ChallengeService.accept] ERROR: Could not process - get ChallengeMatch... #{err}"})

        # TODO need add 
        # params.project
        costData =
          star: challenge.moneyPerOne
          itemid: challenge.id
          note: "Chấp nhận thách thức"
          gameCode: challenge.gameCode
        MoneyService.descStars params.user, costData, (err, usr)->
          if err
            acceptance.destroy()
            LockerService.unlock params.challengeId
            return done(err)

          challenge.playsCount = (challenge.playsCount||0) + 1
          challenge.save (err)->
            if err
              LockerService.unlock params.challengeId
              return done({code: 5000, error: 'Could not process', log: "[ChallengeService.accept] ERROR: Could not process - update Challenge... #{err}"})
            # Locker will be unlock when receive challenge/matchresult or time expire - acceptance user fail
            
            resultData =
              match: acceptance.id
              user: params.user
              score: -1
              time: challenge.score.time + 5000
            TimeJobService.queue timeNow.addMilliseconds(challenge.score.time + 5000), (resultData)->
              ChallengeMatchService.result resultData, (err, status)->
                if err
                  return sails.log.info "[TimeJobService - Challenge Match] ERROR: #{err.log}"
                return sails.log.info "[TimeJobService - Challenge Match] SUCCESS: #{status}"
            return done(acceptance)