async = require('async')
_ = require('lodash')
require('date-utils')

MIN_BROADCAST_SCORE_INTERVAL = 100
BROADCAST_INTERVAL = 500
STARTGAME_COUNTDOWN_SECONDS = 20

MATHROOM_TRIGGER_NAME = 'MATHROOM'
MATHROOM_TRIGGER_TYPE =
  CREATE: 1
  JOIN: 2
  WATCH: 3
  LEAVE: 4
  UNJOIN: 5
  START: 6
  UPDATESCORE: 7
  FINISHGAME: 8
  OWNERREADY: 9
  DISABLE: 10
  AUTOJOIN: 11
  BACKROOM: 12
  ERROR_CREATE: 13
  ERROR_JOIN: 14
  ERROR_WATCH: 15
  ERROR_LEAVE: 16
  ERROR_UNJOIN: 17
  ERROR_START: 18
  ERROR_UPDATESCORE: 19
  ERROR_FINISHGAME: 20
  ERROR_OWNERREADY: 21
  ERROR_DISABLE: 22
  ERROR_AUTOJOIN: 23
  ERROR_BACKROOM: 24

MATHROOM_DATATYPE = 
  USER: 1
  ROOM: 2
  PLAYER_PLAYING: 3
  VIEWER_PLAYING: 4

MAX_PLAYER_RETURN = 4

exports.MATHROOM_TRIGGER_NAME = MATHROOM_TRIGGER_NAME
exports.MATHROOM_TRIGGER_TYPE = MATHROOM_TRIGGER_TYPE

verifyPlayerMoney = (user, room, cb) ->
  if room.nahiRoom
    return cb(true)
  MoneyService.verifyStarMoney user, room.starPerMember, cb


verifyAllPlayersMoney = (room, roomPlayers, cb) ->
  if room.nahiRoom
    return cb(true)
  playerIds = _.pluck(roomPlayers, 'id')
  User.find id: playerIds, (err, users) ->
    if err
      return cb(false)
    if users.length != roomPlayers.length
      return cb(false)
    
    detectMoney = (user, callback) ->
      MoneyService.verifyStarMoney user, room.starPerMember, (isValid) ->
        if !isValid
          return callback('invalid', null)
        return callback(null, true)

    async.map users, detectMoney, (err, r) ->
      if err
        return cb(false)
      return cb(true)


playGameLog = (user) ->
  Game.findOne code: Game.VISIBLE_APIS.MATH, (err, game) ->
    if err || !game
      sails.log.info "Math Game not found"
    else
      logData = [
        user: user
        gameCode: game.code
        category: UserLog.CATEGORY.EXP
        valueChange: MathScore.EXP_PER_SCORE
        reason: 'PLAY GAME'
      ,
        user: user
        gameCode: game.code
        category: UserLog.CATEGORY.ENERGY
        valueChange: -MathScore.ENERGY_PER_SCORE
        reason: 'PLAY GAME'
      ]
      UserLog.create logData, (err, userLog) ->
        if err
          sails.log.info err


descEnergyAndIncExp = (user, cb) ->
  userEnergy = user.energy || 0
  if userEnergy > MathScore.ENERGY_PER_SCORE
    userEnergy = userEnergy - MathScore.ENERGY_PER_SCORE
  else
    userEnergy = 0

  userExp = (user.exp || 0) + MathScore.EXP_PER_SCORE

  LevelService.getUserLevel userExp, (err, userLevel)->
    if err
      return cb(err, null)
    User.update user.id, {energy: userEnergy, exp: userExp, level: userLevel}, (err, us) ->
      if err
        return cb(err, null)
      playGameLog user
      return cb(null, 'success')


descAllPlayersEnergyAndIncExp = (room, roomPlayers) ->  
  playerIds = _.pluck(roomPlayers, 'id')
  User.find id: playerIds, (err, users) ->
    if err
      return false
    if users.length != roomPlayers.length
      return false

    async.map users, descEnergyAndIncExp, (err, r) ->
      if err
        return false
      return true


detectRoomStartable = (room, roomPlayers) ->          
  teams = _.groupBy roomPlayers, (player) ->
    player.team

  countTeams = 0
  _.each teams, (players, team) ->
    playerReadyCount = 0
    _.each players, (player) ->
      playerReadyCount++ if player.ready

    if playerReadyCount != room.memberPerTeam
      return false
    countTeams++

  return (countTeams == room.teamLimit)


chargeAllPlayersMoney = (room, roomPlayers, match) ->  
  if room.nahiRoom
    return true

  Game.findOne code: Game.VISIBLE_APIS.MATH, (err, game) ->
    if err
      sails.log.info err
      return false

    playerIds = _.pluck(roomPlayers, 'id')
    User.find id: playerIds, (err, users) ->
      if err
        return false
      if users.length != roomPlayers.length
        return false

      chargeMoney = (user, callback) ->      
        params = 
          star: room.starPerMember
          itemid: match.id
          project: user.package
          note: "Phí vào phòng chơi"
          gameCode: game.code
        MoneyService.descStars user, params, (err, usr) ->
          if err
            sails.log.info "Could not charge #{params.star} user"
            return callback("Could not charge #{params.star} user", null)
          sails.log.info "Charge #{params.star} for user #{usr.id} successfully"
          return callback(null, "success")

      async.map users, chargeMoney, (err, r) ->
        if err
          return false
        return true


exports.createRoom = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user
  
  if user.energy - MathScore.ENERGY_PER_SCORE < 0
    sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_CREATE, result: {code: 5044, error: 'not enough energy'}}
    return resp.badRequest({code: 5044, error: 'not enough energy'}, null)

  data =
    owner: user.id
    status: MathRoom.STATUSES.OPENED
    name: req.param('name')
    password: req.param('password')
    mode: req.param('mode')
    operator: req.param('operator')
    minLevel: req.param('minLevel')
    timeLimit: req.param('timeLimit')
    teamLimit: req.param('teamLimit')
    memberPerTeam: req.param('memberPerTeam')
    starPerMember: req.param('starPerMember')
    free: req.param('free')
    hasPassword: (req.param('hasPassword') || false)

  verifyPlayerMoney user, data, (isValid) ->
    if !isValid
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_CREATE, result: {code: 5026, error: 'not enough money'}}
      return resp.badRequest({code: 5026, error: 'not enough money'})

    # create room
    MathRoom.create data, (err, room) ->
      if err
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_CREATE, result: {code: 5000, error: err}}
        return resp.badRequest({code: 5000, error: err})
      if !room
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_CREATE, result: {code: 5054, error: 'could not create room'}}
        return resp.badRequest({code: 5054, error: 'could not create room'})

      # Create player
      playerData =
        user: user.id
        mathroom: room.id
        team: 1
        position: 1
        ready: true
        socketId: socketId
      MathRoomPlayer.create playerData, (err, player) ->
        if err
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_CREATE, result: {code: 5000, error: err}}
          return resp.badRequest({code: 5000, error: err})

        room = room.toJSON()
        room.players = [player.mathRoomJSON(user)]
        room.viewers = []

        # Create chat room
        chatRoomData = 
          id: room.id
          kind: Room.KINDS.MATHROOM
          name: "#{room.name} - CHAT ROOM"        

        Room.create chatRoomData, (err, r) ->
          if err
            sails.log.error err

          member =
            user: user.id
            room: room.id
          RoomMember.findOrCreate member, member, (err, rm) ->
            if err
              sails.log.error err
        
        # JOIN room listeners
        sails.sockets.join(req.socket, room.id)
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.CREATE, result: room}
        
        sails.log.info "CREATE ROOM: #{JSON.stringify(room)}"
        
        return resp.ok(room)


exports.watchRoom = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user
  roomid = req.param('roomid')

  startRoomLockKey = "#{MATHROOM_TRIGGER_TYPE.START}-#{roomid}"

  if LockerService.isLocked startRoomLockKey
    sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5150, error: 'the operation is locked'}}
    return resp.badRequest({code: 5150, error: 'the operation is locked'})

  exports.leaveOldRooms user, req.socket, (err) ->
    if err
      sails.log.info err

    cond =
      id: roomid

    MathRoom.findOne cond
    .exec (err, room) ->
      if err || !room
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5055, error: 'not found room'}}
        return resp.badRequest({code: 5055, error: 'not found room'})

      if room.hasPassword && room.password != req.param('password')
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5056, error: 'invalid password'}}
        return resp.badRequest({code: 5056, error: 'invalid password'})

      if room.status == MathRoom.STATUSES.DISABLE
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5147, error: 'room is disabled'}}
        return resp.badRequest({code: 5147, error: 'room is disabled'})

      # return playing
      if room.status == MathRoom.STATUSES.LOCKED
        params = 
          req: req
          socketId: socketId
          room: room
        return exports.watchPlayingRoom params, (err, data) ->
          if err 
            return resp.badRequest(err)
          return resp.ok(data)

      # create viewer   
      viewerData =
        user: user.id
        mathroom: room.id
        socketId: socketId
      MathRoomViewer.create viewerData, (err, viewer) ->
        if err
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5000, error: err}}
          return resp.badRequest({code: 5000, error: err})

        # get room 
        room.getPlayersAndViewers (players, viewers) ->
          room = room.toJSON()
          room.players = players
          room.viewers = viewers
          room.dataType = MATHROOM_DATATYPE.ROOM

          # get viewer JSON
          userJSON = user.mathRoomJSON()
          userJSON.dataType = MATHROOM_DATATYPE.USER

          # add member to chat room
          member =
            user: user.id
            room: room.id
          RoomMember.findOrCreate member, member, (err, rm) ->
            if err
              sails.log.error err

          # SOCKET LISTEN
          sails.sockets.join(req.socket, room.id)

          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.WATCH, result: room}
          sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.WATCH, result: userJSON}, req.socket)
          
          sails.log.info "WATCH ROOM: #{JSON.stringify(room)} --- #{JSON.stringify(userJSON)}"

          resp.ok(room)


exports.watchPlayingRoom = (params, done) ->
  req = params.req
  user = req.user
  socketId = params.socketId
  room = params.room

  MathRoomMatch.findOne {mathroom: room.id}, (err, match) ->
    if err || !match
      sails.log.info err if err
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: {code: 5064, error: 'not found math match'}}
      return done({code: 5064, error: 'not found math match'})

    async.parallel 
      # get players data (same as WATCH_ROOM data)
      players: (cb) ->
        match.getMathRoomPlayers (players) ->      
          cb(null, players)

      # get sorted playing players (same as UPDATE_SCORE data)
      playingPlayers: (cb) ->
        match.getPlayingPlayers (players) ->      
          cb(null, players)

    , (err, result) ->

      # add member to chat room
      member =
        user: user.id
        room: room.id
      RoomMember.findOrCreate member, member, (err, rm) ->
        if err
          sails.log.error err

      # emit data 
      room.getViewers (viewers) ->
        player = _.find(result.playingPlayers, {id: user.id})
        playerIndex = _.findIndex(result.playingPlayers, {id: user.id})
        isPlayer = (playerIndex > -1)

        if isPlayer     
          async.parallel 
            # add user to player 
            mathroomPlayer: (cb) ->
              playerData = 
                user: user.id
                mathroom: room.id
                team: player.team
                position: player.position
                ready: true
                socketId: socketId
              MathRoomPlayer.create playerData, (err, player) ->
                if err 
                  return cb({code: 5000, error: err})
                return cb(null, player)

            # re binding socket 
            reBindSocket: (cb) ->
              MathRoomMatchPlayer.update {user: user.id}, {socketId: socketId}, (err, matchPlayers) ->
                if err
                  return cb({code: 5000, error: err})
                return cb(null, matchPlayers)

          , (err, rs) ->
            if err
              sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: err}
              return done(err)

            # data for player
            data = room.toJSON()
            data.dataType = MATHROOM_DATATYPE.PLAYER_PLAYING
            data.players = result.players
            data.viewers = viewers   
            data.topPlayers = result.playingPlayers.slice(0, MAX_PLAYER_RETURN)
            data.remainingTime = match.remainingTime
            data.yourRank = playerIndex
            data.yourScore = player.score
            data.terms = match.terms
            data.matchid = match.id
            
            userJSON = rs.mathroomPlayer.autoJoinRoomJSON(user)

            # socket listen
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.WATCH, result: data}
            sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.AUTOJOIN, result: userJSON}, req.socket)
           
            sails.sockets.join(req.socket, room.id)

            sails.log.info "WATCH ROOM PLAYER: #{JSON.stringify(data)} -- #{JSON.stringify(userJSON)}"

            return done(null, data)


        else 
          async.parallel 
            # add user to viewer  
            mathroomViewer: (cb) -> 
              viewerData =
                user: user.id
                mathroom: room.id
                socketId: socketId
              MathRoomViewer.create viewerData, (err, viewer) ->
                if err
                  return cb({code: 5000, error: err})
                return cb(null, viewer)

            # re binding socket 
            reBindSocket: (cb) ->
              MathRoomViewer.update {user: user.id}, {socketId: socketId}, (err, viewers) ->
                if err                  
                  return cb({code: 5000, error: err})
                return cb(null, viewers)

          , (err, rs) ->
            if err
              sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_WATCH, result: err}
              return done(err)
          
            # data for viewer
            data = room.toJSON()
            data.dataType = MATHROOM_DATATYPE.VIEWER_PLAYING
            data.players = result.players
            data.viewers = viewers
            data.topPlayers = result.playingPlayers
            data.remainingTime = match.remainingTime
            data.matchid = match.id

            userJSON = user.mathRoomJSON()
            userJSON.dataType = MATHROOM_DATATYPE.USER

            # socket listen
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.WATCH, result: data}
            sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.WATCH, result: userJSON}, req.socket)
           
            sails.sockets.join(req.socket, room.id)

            sails.log.info "WATCH ROOM VIEWER: #{JSON.stringify(data)} -- #{JSON.stringify(userJSON)}"

            return done(null, data)


exports.leaveOldRooms = (user, socket, done) ->
  cond = 
    user: user.id

  leaveRoom = (mathRoomUsers, cb) ->
    async.each mathRoomUsers, (mathRoomUser, next) ->
      params =           
        roomid: mathRoomUser.mathroom
        user: user
        socket: socket
        silentMode: true
      exports.leaveRoom params, (err, room) ->    
        next()
    , (err) ->
      cb(err)

  MathRoomPlayer.find cond, (err, players) ->
    if err 
      sails.log.info(code: 5000, error: err)

    leaveRoom players, (err) ->
      if err 
        sails.log.info err

      MathRoomViewer.find cond, (err, viewers) ->
        if err 
          sails.log.info(code: 5000, error: err)

        leaveRoom viewers, (err) ->
          if err 
            sails.log.info err

          return done()


joinRoom = (req, room, params, done)=>
  user = req.user

  startRoomLockKey = "#{MATHROOM_TRIGGER_TYPE.START}-#{room.id}"
  joinRoomPositionLockKey = "#{MATHROOM_TRIGGER_TYPE.JOIN}-#{room.id}-#{params.team}-#{params.position}"
  joinRoomUserLockKey = "#{MATHROOM_TRIGGER_TYPE.JOIN}-#{room.id}-#{user.id}"

  # check locker
  if LockerService.isLocked startRoomLockKey
    return done({code: 5150, error: 'the operation is locked'})
    
  if LockerService.isLocked joinRoomPositionLockKey
    return done({code: 5150, error: 'the operation is locked'})
      
  if LockerService.isLocked joinRoomUserLockKey
    return done({code: 5153, error: 'user is joining room'})
  
  # lock this operation
  LockerService.lock joinRoomUserLockKey
  LockerService.lock joinRoomPositionLockKey

  socketId = sails.sockets.id(req.socket)

  if room.status == MathRoom.STATUSES.LOCKED
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5146, error: 'room is playing'}, null)

  if room.status == MathRoom.STATUSES.DISABLE
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5147, error: 'room is disabled'}, null)

  if user.energy - MathScore.ENERGY_PER_SCORE < 0
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5044, error: 'not enough energy'}, null)

  if room.hasPassword && room.password != params.password
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5056, error: 'invalid password'}, null)

  if room.minLevel > user.level
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5057, error: 'invalid level'}, null)

  params.team = parseInt(params.team || 0)
  params.position = parseInt(params.position || 0)

  if params.team < 1 || params.team > room.teamLimit || params.position < 1 || params.position > room.memberPerTeam
    LockerService.unlock joinRoomUserLockKey
    LockerService.unlock joinRoomPositionLockKey
    return done({code: 5058, error: 'must join a team'}, null)

  # verify user money
  verifyPlayerMoney user, room, (isValid) ->
    if !isValid
      LockerService.unlock joinRoomUserLockKey
      LockerService.unlock joinRoomPositionLockKey
      return done({code: 5026, error: 'not enough money'}, null)

    # check whether user has joined 
    joinedCond =
      user: user.id
      mathroom: room.id
    MathRoomPlayer.findOne joinedCond, (err, player) ->
      if err 
        LockerService.unlock joinRoomUserLockKey
        LockerService.unlock joinRoomPositionLockKey
        return done({code: 5000, error: err}, null)
      if player
        LockerService.unlock joinRoomUserLockKey
        LockerService.unlock joinRoomPositionLockKey
        return done({code: 5059, error: 'you have joined room'}, null)
    
      # check whether the team and position have player already
      joinedCond =
        mathroom: room.id
        team: params.team
        position: params.position
      MathRoomPlayer.findOne joinedCond, (err, player) ->
        if err 
          LockerService.unlock joinRoomUserLockKey
          LockerService.unlock joinRoomPositionLockKey
          return done({code: 5000, error: err}, null)
        if player
          LockerService.unlock joinRoomUserLockKey
          LockerService.unlock joinRoomPositionLockKey
          return done({code: 5150, error: 'this position have player already'}, null)

        # remove from viewer
        viewerCond = 
          user: user.id
          mathroom: room.id

        MathRoomViewer.destroy viewerCond, (err, destroyedViewers) ->
          if err   
            LockerService.unlock joinRoomUserLockKey
            LockerService.unlock joinRoomPositionLockKey       
            return done({code: 5000, error: err}, null)

          # create player
          playerData = 
            user: user.id
            mathroom: room.id
            team: params.team
            position: params.position
            ready: true
            socketId: socketId

          MathRoomPlayer.create playerData, (err, player) ->
            if err 
              LockerService.unlock joinRoomUserLockKey
              LockerService.unlock joinRoomPositionLockKey
              return done({code: 5000, error: err}, null)
          
            room.getPlayersAndViewers (players, viewers) ->
              room = room.toJSON()
              room.players = players
              room.viewers = viewers
              room.dataType = MATHROOM_DATATYPE.ROOM

              if detectRoomStartable(room, players)
                kickOffGamePlay {roomid: room.id, socketId: socketId}, (err, match) ->
                  if err
                    sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_START, result: err}
                    return

              # AUTOJOIN room trigger
              if params.isAutoJoin
                userJSON = player.autoJoinRoomJSON(user)
                userJSON.dataType = MATHROOM_DATATYPE.USER

                sails.sockets.join(req.socket, room.id)   
                sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.AUTOJOIN, result: room}
                sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.AUTOJOIN, result: userJSON}, req.socket)         
                sails.log.info "AUTOJOIN ROOM: #{JSON.stringify(room)}"

              # JOIN room trigger
              else
                userJSON = player.joinRoomJSON()

                sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.JOIN, result: userJSON})
                sails.log.info "JOIN ROOM: #{JSON.stringify(userJSON)}"

              # add member to chat room
              member =
                user: user.id
                room: room.id
              RoomMember.findOrCreate member, member, (err, rm) ->
                if err
                  sails.log.error err

              LockerService.unlock joinRoomUserLockKey
              LockerService.unlock joinRoomPositionLockKey
              return done(null, room)


exports.playRoom = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user

  cond =
    id: req.param('roomid')

  MathRoom.findOne cond, (err, room) ->
    if err || !room
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_JOIN, result: {code: 5055, error: "could not found room"}}
      return resp.badRequest({code: 5055, error: "could not found room"})

    params = 
      password: req.param('password')
      team: req.param('team')
      position: req.param('position')
      isAutoJoin: false

    joinRoom req, room, params, (err, rtRoom) ->
      if err
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_JOIN, result: err}
        return resp.badRequest(err)

      return resp.ok(true)


exports.autoJoin = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user

  if user.energy - MathScore.ENERGY_PER_SCORE < 0
    sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_AUTOJOIN, result: {code: 5044, error: "not enough energy"}}
    return resp.badRequest({code: 5044, error: "not enough energy"})

  exports.leaveOldRooms user, req.socket, (err) ->
    if err
      sails.log.info err

    cond = 
      hasPassword: false
      status: MathRoom.STATUSES.OPENED
      minLevel: {'<=': user.level}

    MathRoom.find cond
    .exec (err, rooms) ->
      if err || !rooms || rooms.length == 0
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_AUTOJOIN, result: {code: 5060, error: "could not find any avail room"}}
        return resp.badRequest({code: 5060, error: "could not find any avail room"})
      
      # find the position to join
      getTeamAndPosition = (room, done) ->
        room.getPlayers (players) ->
          teams = _.groupBy(players, 'team')   

          teamIndex = 1
          while teamIndex <= room.teamLimit          
            if !teams[teamIndex.toString()] || teams[teamIndex.toString()].length < room.memberPerTeam
              position = 1
              while position <= room.memberPerTeam
                if !_.find(teams[teamIndex.toString()], {position: position})
                  return done({
                    team: teamIndex
                    position: position  
                  })
                position++          
            teamIndex++
          return done(null)

      # loop on room list and try to join one
      lookupRoom = (rooms, next) ->
        if rooms.length == 0
          return next("not found", null)
        room = rooms.shift(0)
        getTeamAndPosition room, (teamPosition) ->
          if !teamPosition
            return lookupRoom(rooms, next)

          params = 
            password: null
            team: teamPosition.team
            position: teamPosition.position
            isAutoJoin: true

          joinRoom req, room, params, (err, rtRoom) ->
            if !err
              return next(null, rtRoom)

            lookupRoom(rooms, next)

      lookupRoom rooms, (err, room) ->
        if err
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_AUTOJOIN, result: {code: 5060, error: 'not found any avail room'}}
          return resp.badRequest({code: 5060, error: 'not found any avail room'})

        return resp.ok(room)


exports.leaveRoom = (params, done)=>
  silentMode = params.silentMode || false

  startRoomLockKey = "#{MATHROOM_TRIGGER_TYPE.START}-#{params.roomid}"

  if LockerService.isLocked startRoomLockKey
    if !silentMode
      return done({code: 5150, error: 'the operation is locked'})

  socketId = sails.sockets.id(params.socket)
  user = params.user

  cond =
    id: params.roomid

  MathRoom.findOne cond, (err, room) ->
    if err || !room
      if !silentMode 
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_LEAVE, result: {code: 5055, error: "could not found room"}}
      return done({code: 5055, error: "could not found room"})

    cond = 
      mathroom: params.roomid
      user: user.id

    # remove from viewers
    MathRoomViewer.destroy cond, (err, destroyedViewers) ->
      if err
        if !silentMode
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_LEAVE, result: {code: 5061, error: 'could not leave this room'}}
        return done({code: 5061, error: 'could not leave this room'})

      # remove from players
      MathRoomPlayer.destroy cond, (err, destroyedPlayers) ->
        if err
          if !silentMode
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_LEAVE, result: {code: 5061, error: 'could not leave this room'}}
          return done({code: 5061, error: 'could not leave this room'})

        # remove member from chat room
        member =
          user: user.id
          room: params.roomid
        RoomMember.destroy member, (err, rm) ->
          if err
            sails.log.error err

        room.getPlayers (players) ->
          # reset room owner
          if user.id == room.owner && !room.nahiRoom && room.status != MathRoom.STATUSES.DISABLE
            if players[0]? 
              room.owner = players[0].id
            else
              room.owner = null
          
          room.save () ->
            # LEAVE room
            result =
              id: user.id
              roomOwner: room.owner

            sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.LEAVE, result: result})
            sails.sockets.leave(params.socket, room.id)

            # detect turn off room
            if players.length < 1 && !room.nahiRoom && room.status != MathRoom.STATUSES.DISABLE
              room.status = MathRoom.STATUSES.DISABLE
              room.save () ->
                sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.DISABLE, result: {roomId: room.id}})
                sails.log.info "DISABLED ROOM: #{room.id}"

            sails.log.info "LEAVE ROOM: #{JSON.stringify(result)}"
          
            return done(null, result)


exports.jumpToWatcher = (params, done)=>
  startRoomLockKey = "#{MATHROOM_TRIGGER_TYPE.START}-#{params.roomid}"

  if LockerService.isLocked startRoomLockKey
    return done({code: 5150, error: 'the operation is locked'})
      
  socketId = sails.sockets.id(params.socket)
  user = params.user

  cond = 
    id: params.roomid

  MathRoom.findOne cond, (err, room) ->
    if err || !room
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5055, error: "could not found room"}}
      return done({code: 5055, error: "could not found room"})
    
    if room.status == MathRoom.STATUSES.LOCKED
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5146, error: 'room is playing'}}
      return done({code: 5146, error: 'room is playing'})

    if room.status == MathRoom.STATUSES.DISABLE
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5147, error: 'room is disabled'}}
      return done({code: 5147, error: 'room is disabled'})

    data = 
      mathroom: params.roomid
      user: user.id
  
    # remove from players
    MathRoomPlayer.destroy data, (err, destroyedPlayers) ->
      if err
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5000, error: err}}
        return done({code: 5000, error: err})

      if destroyedPlayers.length == 0
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5151, error: 'user is not player'}}
        return done({code: 5151, error: 'user is not player'})
      
      # remove from viewers
      MathRoomViewer.destroy data, (err, destroyedViewers) ->
        if err
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5000, error: err}}
          return done({code: 5000, error: err})

        # create viewer
        data.socketId = socketId

        MathRoomViewer.create data, (err, viewer) ->
          if err
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_UNJOIN, result: {code: 5000, error: err}}
            return done({code: 5000, error: err})

          room.getPlayers (players) ->
            # reset room owner
            if user.id == room.owner && !room.nahiRoom && room.status != MathRoom.STATUSES.DISABLE
              if players[0]? 
                room.owner = players[0].id
              else
                room.owner = null

            room.save () ->
              # send UNJOIN trigger
              userJSON = 
                id: destroyedPlayers[0].user
                team: destroyedPlayers[0].team
                position: destroyedPlayers[0].position
                roomOwner: room.owner
              sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.UNJOIN, result: userJSON})

              # detect turn off room
              if players.length < 1 && !room.nahiRoom && room.status != MathRoom.STATUSES.DISABLE
                room.status = MathRoom.STATUSES.DISABLE
                room.save () ->
                  sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.DISABLE, result: {roomId: room.id}})
                  sails.sockets.leave(params.socket, room.id)
                  sails.log.info "DISABLED ROOM: #{room.id}"
              
              sails.log.info "UNJOIN: #{JSON.stringify(userJSON)}"

              return done(null, userJSON)


assignWinItems = (winItems, match) ->
  cond = 
    code: _.pluck(winItems, 'itemCode')
    isActive: true

  Item.find cond, (err, items) ->
    if err || !items
      return

    assignItems = []
    hashCodes = _.zipObject(_.pluck(items, 'code'), items)

    _.each winItems, (winItem) ->
      if hashCodes[winItem.itemCode]
        assignItems.push({rank: winItem.rank, item: hashCodes[winItem.itemCode]})
    
    match.winItems = assignItems
    MathRoomMatch.update {id: match.id}, {winItems: assignItems}, (err) ->
      if err 
        sails.log.info err


kickOffGamePlay = (params, done) ->
  startRoomLockKey = "#{MATHROOM_TRIGGER_TYPE.START}-#{params.roomid}"

  if LockerService.isLocked startRoomLockKey
    return done({code: 5150, error: 'the operation is locked'})

  # lock this operation
  LockerService.lock startRoomLockKey


  params.manualKickOff ||= false

  cond = 
    id: params.roomid
    status: MathRoom.STATUSES.OPENED

  MathRoom.findOne cond, (err, room) ->
    if err || !room
      LockerService.unlock startRoomLockKey
      return done({code: 5055, error: "could not found room"}, null)

    room.getPlayers (players) ->
      if players.length == 0
        LockerService.unlock startRoomLockKey
        return done({code: 5062, error: 'can not start'}, null)

      if !detectRoomStartable(room, players) && !params.manualKickOff
        LockerService.unlock startRoomLockKey
        return done({code: 5062, error: 'can not start'}, null)

      verifyAllPlayersMoney room, players, (canStart) ->
        if !canStart
          LockerService.unlock startRoomLockKey
          return done({code: 5063, error: 'players are not enough money'}, null)

        room.status = MathRoom.STATUSES.LOCKED
        room.save (err, rt) ->
          if err
            LockerService.unlock startRoomLockKey
            return done({code: 5000, error: err}, null)

          # create math room match
          timeNow = new Date() 
          startTime = _.clone(timeNow).addSeconds(STARTGAME_COUNTDOWN_SECONDS)
          endTime = _.clone(startTime).addSeconds(room.timeLimit)

          data = 
            owner: room.owner
            mathroom: room.id
            startTime: startTime
            endTime: endTime
            status: MathRoomMatch.STATUSES.PLAYING
            terms: MathQuestionService.getTerms(room, room.timeLimit * 1.5)
            remainingTime: room.timeLimit * 1000
            # caching data
            name: room.name
            mode: room.mode
            minLevel: room.minLevel
            timeLimit: room.timeLimit
            teamLimit: room.teamLimit
            memberPerTeam: room.memberPerTeam
            starPerMember: room.starPerMember
            nahiRoom: room.nahiRoom            
            playboards: [] # playboards will be populated after the match finished 

          MathRoomMatch.create data, (err, match) ->
            if err
              room.status = MathRoom.STATUSES.OPENED
              room.save()
              LockerService.unlock startRoomLockKey
              return done({code: 5000, error: err}, null)

            # create match players on Redis
            matchPlayers = []
            teams = _.groupBy(players, 'team')
            _.each teams, (members, team) ->
              _.each members, (member) ->
                matchPlayers.push
                  mathroommatch: match.id
                  user: member.id
                  team: member.team
                  position: member.position
                  score: 0
                  updatedAt: timeNow                  
                  socketId: member.socketId
                  endTime: endTime

            MathRoomMatchPlayer.create matchPlayers, (err, matchPlayers) ->
              if err
                room.status = MathRoom.STATUSES.OPENED
                room.save()
                LockerService.unlock startRoomLockKey
                return done({code: 5000, error: err}, null)

            chargeAllPlayersMoney(room, players, match)
            descAllPlayersEnergyAndIncExp(room, players)
           
            # emit to room subscribers         
            sails.log.info "START ROOM.........................."
            sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.START, result: {matchid: match.id, terms: match.terms}})

            # caching winItems
            assignWinItems(room.winItems, match)

            # match finish job
            jobFunc = () ->
              MathRoomMatchService.detectFinishMatch(match, params.socketId)
            TimeJobService.queue(match.endTime, jobFunc)

            # broadcast math match score to users on room every interval              
            broadcastMathMatchScore(match, BROADCAST_INTERVAL)

            LockerService.unlock startRoomLockKey
            return done(null, match)


# broadcast math match score to users on room every [interval] ms 
broadcastMathMatchScore = (match, interval) ->
  if interval < MIN_BROADCAST_SCORE_INTERVAL
    interval = MIN_BROADCAST_SCORE_INTERVAL

  addBroadcastJobToQueue = (broadcastTime, remainingTime) ->
    TimeJobService.queue broadcastTime, () ->
      MathRoomMatchService.broadcastScore(match, remainingTime)

  broadcastTime = match.startTime
  remainingTime = match.timeLimit * 1000 # (in milisecond)
  
  while broadcastTime < match.endTime
    addBroadcastJobToQueue(broadcastTime, remainingTime) 

    broadcastTime = broadcastTime.addMilliseconds(interval)
    remainingTime -= interval


exports.backRoom = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user

  roomid = req.param('roomid')

  MathRoom.findOne roomid, (err, room) ->
    if err || !room
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5055, error: "could not found room"}}
      return resp.badRequest({code: 5055, error: "could not found room"})

    if room.status == MathRoom.STATUSES.LOCKED
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5146, error: 'room is playing'}}
      return resp.badRequest({code: 5146, error: 'room is playing'})

    if room.status == MathRoom.STATUSES.DISABLE
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5147, error: 'room is disabled'}}
      return resp.badRequest({code: 5147, error: 'room is disabled'})

    if room.owner == user.id      
      cond = 
        user: user.id
        mathroom: roomid
        
      MathRoomPlayer.findOne cond, (err, owner) ->          
        if owner
          if user.energy - MathScore.ENERGY_PER_SCORE < 0
            sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5044, error: 'not enough energy'}}
            return resp.badRequest({code: 5044, error: 'not enough energy'}, null)

          MoneyService.verifyStarMoney user, room.starPerMember, (isValid) ->
            if !isValid
              sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5026, error: 'not enough money'}}
              return resp.badRequest({code: 5026, error: 'not enough money'}, null)

            if owner.ready 
              sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.OWNERREADY, result: {id: user.id}})
              return

            owner.ready = true
            owner.save (err)->
              if err
                sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5000, error: err}}
                return resp.badRequest({code: 5000, error: err})

              # return room to user
              room.getPlayersAndViewers (players, viewers) ->
                room = room.toJSON()
                room.players = players
                room.viewers = viewers

                sails.log.info "OWNERREADY: #{user.id}"
                sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.BACKROOM, result: room}
                sails.sockets.broadcast(room.id, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.OWNERREADY, result: {id: user.id}}, req.socket)
              
                if detectRoomStartable(room, players)
                  kickOffGamePlay {roomid: room.id, socketId: socketId}, (err, match) ->
                    if err
                      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_START, result: {code: 5000, error: err}}
                      return

                return resp.ok(room)
        else
          sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_BACKROOM, result: {code: 5066, error: "you are not join room"}}
          return resp.badRequest({code: 5066, error: "you are not join room"})
          
    else          
      # return room to user
      room.getPlayersAndViewers (players, viewers) ->
        room = room.toJSON()
        room.players = players
        room.viewers = viewers
        
        sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.BACKROOM, result: room}      
        return resp.ok(room)



exports.startRoom = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  user = req.user

  params = 
    user: user
    roomid: req.param('roomid')
    socketId: socketId
    manualKickOff: true

  kickOffGamePlay params, (err, match) ->
    if err      
      sails.sockets.emit socketId, MATHROOM_TRIGGER_NAME, {type: MATHROOM_TRIGGER_TYPE.ERROR_START, result: err}
      return resp.badRequest(err)

    return resp.ok(match)


exports.listNahiRooms = (req, resp) ->
  page = req.param('page') || 1
  limit = req.param('limit') || 10

  MathRoom.find {nahiRoom: true}
  .sort({createdAt: 'desc'})
  .paginate({page: page, limit: limit})
  .exec (err, rooms) -> 
    if err
      return resp.badRequest({code: 5000, error: err},null)

    async.map rooms, (room, cb) ->
      cb(null, room.publicJSON())
    , (err, result) ->
      return resp.ok(result)


exports.listRooms = (req, resp) ->
  page = req.param('page') || 1
  limit = req.param('limit') || 10

  MathRoom.find
    status: { '!': MathRoom.STATUSES.DISABLE}
    $or: [{nahiRoom: false}, {nahiRoom: ''}]
  .sort({createdAt: 'desc'})
  .paginate({page: page, limit: limit})
  .exec (err, rooms) -> 
    if err
      return resp.badRequest({code: 5000, error: err})

    async.map rooms, (room, cb) ->
      cb(null, room.publicJSON())
    , (err, result) ->
      return resp.ok(result)