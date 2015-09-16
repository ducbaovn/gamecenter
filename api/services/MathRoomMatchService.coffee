_ = require('lodash')
async = require('async')
require('date-utils')

MathRoomService = require('./MathRoomService')
MATHROOM_TRIGGER_NAME = MathRoomService.MATHROOM_TRIGGER_NAME
MATHROOM_TRIGGER_TYPE = MathRoomService.MATHROOM_TRIGGER_TYPE

MAX_PLAYER_RETURN = 4

exports.broadcastScore = (match, currentRemainingTime) ->
  cond = 
    id: match.mathroom
    status: MathRoom.STATUSES.LOCKED

  MathRoom.findOne cond, (err, room) ->
    if err || !room
      sails.log.info err if err
      return 

    MathRoomMatch.findOne match.id, (err, match) ->
      if err || !match
        sails.log.info err if err
        return 

      match.getPlayingPlayers (players) ->
        match.remainingTime = currentRemainingTime 
        match.save()

        # BROADCAST SCORE TO PLAYERS
        resultForPlayer = {}
        resultForPlayer.remainingTime = currentRemainingTime 
        resultForPlayer.topPlayers = players.slice(0, MAX_PLAYER_RETURN)

        _.each players, (player, rank) ->        
          resultForPlayer.yourRank = rank + 1
          resultForPlayer.yourScore = player.score

          sails.log.info "UPDATE SCORE (PLAYER): #{player.socketId} #{JSON.stringify(resultForPlayer)}"
          sails.sockets.emit(player.socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.UPDATESCORE, result: resultForPlayer})

        # BROADCAST SCORE TO VIEWERS
        resultForViewer = {}
        resultForViewer.remainingTime = currentRemainingTime          
        resultForViewer.topPlayers = players
          
        room.getViewers (viewers) ->
          _.each viewers, (viewer) ->
            sails.log.info "UPDATE SCORE (VIEWER): #{viewer.socketId} #{JSON.stringify(resultForViewer)}"                        
            sails.sockets.emit(viewer.socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.UPDATESCORE, result: resultForViewer})


exports.newScore = (req, resp) ->
  socketId = sails.sockets.id(req.socket)
  user = req.user

  cond = 
    id: req.param('matchid')
    status: MathRoomMatch.STATUSES.PLAYING
  MathRoomMatch.findOne cond, (err, match) ->
    if err || !match
      sails.log.info err if err
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UPDATESCORE, result: {code: 5064, error: 'not found math match'}}
      return resp.badRequest({code: 5064, error: 'not found math match'})
   
    cond =
      mathroommatch: req.param('matchid')
      user: user.id

    MathRoomMatchPlayer.findOne cond, (err, player) ->
      if err || !player
        sails.log.info err if err
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UPDATESCORE, result: {code: 5064, error: 'not found math match player'}}
        return resp.badRequest({code: 5152, error: 'not found math match player'})
    
      player.score ||= 0
      player.score += 1    
      player.updatedAt = new Date()
      player.save()

      MathRoom.updateUpdatedAt(match.mathroom, ()->)
    
    resp.ok(true)

exports.misScore = (req, resp) ->
  socketId = sails.sockets.id(req.socket)
  user = req.user

  cond = 
    id: req.param('matchid')
    status: MathRoomMatch.STATUSES.PLAYING

  MathRoomMatch.findOne cond, (err, match) ->
    if err || !match
      sails.log.info err if err
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UPDATESCORE, result: {code: 5064, error: 'not found math match'}}
      return resp.badRequest({code: 5064, error: 'not found math match'})
   
    cond =
      mathroommatch: req.param('matchid')
      user: user.id

    MathRoomMatchPlayer.findOne cond, (err, player) ->
      if err || !player
        sails.log.info err if err
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UPDATESCORE, result: {code: 5064, error: 'not found math match player'}}
        return resp.badRequest({code: 5152, error: 'not found math match player'})
      
      if player.score > 0
        player.score -= 1 
        player.updatedAt = new Date()   
        player.save()
        
        MathRoom.updateUpdatedAt(match.mathroom, ()->)
    
    resp.ok(true)


exports.detectFinishMatch = (match, socketId) ->
  sails.log.info "YAY! MATCH IS FINISHED....."

  timeNow = new Date()
  timeNow.addMilliseconds(500)

  if match.endTime <= timeNow && match.status == MathRoomMatch.STATUSES.PLAYING
    MathRoomMatch.findOne match.id, (err, match) ->
      if err || !match
        if socketId
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_FINISHGAME, result: {code: 5000, error: 'could not found math match'}}
        return
      
      MathRoom.findOne match.mathroom, (err, room) ->
        if err || !room
          if socketId
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_FINISHGAME, result: {code: 5000, error: 'could not found room'}}
          return      

        room.getViewers (viewers) ->  
          result = {}

          async.parallel 
            # reset room
            reset: (cb) ->                  
              resetMatchRoom room, (err, owner) ->
                if err
                  return cb(err)            
                result.roomOwner = owner
                return cb()
          
            # get result boards
            topboards: (cb) ->
              getTopBoards match, (topboards) ->    
                result.playboards = topboards
                return cb()

          , (err, r) ->
            if err
              if socketId
                sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_FINISHGAME, result: {code: 5000, error: err}}
              return

            # offer for winners
            match.playboards = result.playboards
            offerWinners match, (offers) ->
              result.winnerStar = offers.winnerStar
              result.roomFeeStar = offers.roomFeeStar
              result.winnerReceivedStar = offers.winnerReceivedStar
              result.loserReceivedStar = offers.loserReceivedStar

              # FINISH GAME 
              match.destroy()
              MathRoomMatchPlayer.destroy mathroommatch: match.id

              # broadcast star and received item to each player
              _.each result.playboards, (team, teamIndex) ->
                _.each team.players, (player) ->
                  result.yourRank = player.rank

                  if teamIndex == 0
                    result.yourStar = result.winnerReceivedStar
                  else
                    result.yourStar = result.loserReceivedStar

                  receivedItem = _.find(offers.receivedItems, {id: player.id})
                  if receivedItem
                    result.yourReceivedItem = receivedItem.item.publicJSON()
                  else
                    result.yourReceivedItem = null

                  sails.log.info "FINISH GAME (PLAYER): #{player.socketId} #{JSON.stringify(result)}"
                  sails.sockets.emit(player.socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.FINISHGAME, result: result})
                  
              # broadcast star and received item to each viewers
              delete result.yourRank
              delete result.yourStar
              delete result.yourReceivedItem
              _.each viewers, (viewer) ->
                sails.log.info "FINISH GAME (VIEWER): #{viewer.socketId} #{JSON.stringify(result)}"
                sails.sockets.emit(viewer.socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.FINISHGAME, result: result})


getTopBoards = (match, done) ->
  match.getPlayers (players) ->
    teams = _.groupBy(players, 'team')
    
    # summary each team score 
    playboards = []
    _.each teams, (members, team) ->
      finishGameMembers = []
      teamScore = 0
      lastScoreUpdatedAt = new Date(2000, 0, 1)    

      _.each members, (member) ->
        teamScore += member.score
        if member.updatedAt > lastScoreUpdatedAt
          lastScoreUpdatedAt = member.updatedAt

        finishMember = member.finishGameJSON()
        finishMember.rank = _.findIndex(players, {user: member.user}) + 1

        finishGameMembers.push(finishMember)

      playboards.push
        team: team
        score: teamScore
        scoreUpdatedAt: lastScoreUpdatedAt
        players: finishGameMembers

    # sort top boards
    playboards = _.sortByOrder(playboards, ['score', 'scoreUpdatedAt'], [false, true])
    _.each playboards, (team) ->
      delete team.scoreUpdatedAt

    return done(playboards)


resetMatchRoom = (room, done) ->  
  # delete players
  cond =
    mathroom: room.id
    user:
      '!': room.owner
  MathRoomPlayer.destroy cond, (err, players) ->
    if err
      return done({code: 5000, error: err})

    # add players to viewer
    MathRoomViewer.create players, (err, viewers) ->
      if err
        return done({code: 5000, error: err})

      # set room owner ready = false
      if room.nahiRoom
        room.status = MathRoom.STATUSES.OPENED
        room.save () ->
          return done(null, null)

      else
        MathRoomPlayer.update {mathroom: room.id, user: room.owner}, {ready: false}, (err, roomOwner) ->
          if err
            return done({code: 5000, error: err})

          room.status = MathRoom.STATUSES.OPENED
          room.save () ->
            return done(null, room.owner)


offerWinners = (match, done) ->
  offers = 
    winnerStar: 0
    roomFeeStar: 0
    winnerReceivedStar: 0
    loserReceivedStar: 0
    # [
    #   {
    #     id: userid
    #     item: itemObj
    #   }
    # ]
    receivedItems: null

  winTeam = match.playboards?[0]

  if !winTeam || winTeam.score == 0
    return done(offers)
    
  # nahi room: offer items
  if match.nahiRoom
    offerNahiRoomWinners match, (receivedItems) ->
      offers.receivedItems = receivedItems
      return done(offers)

  # free room: offer money
  else 
    winnerStar = match.starPerMember * (match.teamLimit - 1)
    roomFeeStar = Math.ceil(winnerStar * MathRoomMatch.FEE)    
    winnerReceivedStar = winnerStar - roomFeeStar
    loserReceivedStar = 0

    # refund money for winner  
    starWinnerReceived = winnerReceivedStar + match.starPerMember
    
    Game.findOne code: Game.VISIBLE_APIS.MATH, (err, game) ->
      if err
        sails.log.info err

      refundWinnerMoney = (user, cb) ->
        params = 
          star: starWinnerReceived
          project: user.package
          note: "Thắng ở phòng chơi"
          gameCode: game.code
        MoneyService.incStars user, params, (err, usr) ->
          if err
            sails.log.info err
            return cb(err)
          return cb()

      winnerIds = _.pluck(winTeam.players, 'id')
      User.find id: winnerIds, (err, users) ->
        if err 
          sails.log.info err
          return

        async.each users, refundWinnerMoney, (err) ->
          if err
            sails.log.info err

    offers.winnerStar = winnerStar
    offers.roomFeeStar = roomFeeStar
    offers.winnerReceivedStar = winnerReceivedStar
    offers.loserReceivedStar = loserReceivedStar
    return done(offers)


offerNahiRoomWinners = (match, done) ->
  receivedItems = []
  MathRoomMatch.findOne match.id, (err, match) ->
    if err || !match || !match.nahiRoom || !match.winItems
      return done(receivedItems)

    rank = 1
    _.each match.playboards, (team) ->      
      rankItem = _.find(match.winItems, {rank: rank})
      if rankItem
        _.each team.players, (player) ->
          receivedItems.push({
            id: player.id
            item: rankItem
          })  
          MathItemService.addItemUserGame(rankItem, player, Game.VISIBLE_APIS.MATH)
      rank++

    return done(receivedItems)



