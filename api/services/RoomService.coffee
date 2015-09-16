_ = require('lodash')

ROOM_EVENT_NAMES =
  USER_JOIN: 'CHAT:ROOM:USER:JOIN'
  USER_LEAVE: 'CHAT:ROOM:USER:LEAVE'
  MESSAGE: 'CHAT:ROOM:MESSAGE'

ROOM_ERROR_EVENT_NAMES =
  USER_JOIN: 'CHAT_ERROR:ROOM:USER:JOIN'
  USER_LEAVE: 'CHAT_ERROR:ROOM:USER:LEAVE'
  MESSAGE: 'CHAT_ERROR:ROOM:MESSAGE'

ROOM_SUCCESS_EVENT_NAMES =
  USER_JOIN: 'CHAT_SUCCESS:ROOM:USER:JOIN'
  USER_LEAVE: 'CHAT_SUCCESS:ROOM:USER:LEAVE'
  MESSAGE: 'CHAT_SUCCESS:ROOM:MESSAGE'

joinRoom = (user, roomid)->
  data = 
    user: user.id
    room: roomid
  RoomMember.findOrCreate data, (e, rm)->
    sails.log.info e
    sails.log.info rm

exports.join = (req, resp)=>
  roomid = req.param('roomid')
  Room.findOne {id: roomid}, (e, room)->
    if e || !room
      return resp.send(false)

    # TODO
    # need update permission
    sails.sockets.join(req.socket, roomid)

    socketId = sails.sockets.id(req.socket)
    user = req.user.chatJSON()
    if !user
      sails.sockets.emit socketId, ROOM_ERROR_EVENT_NAMES.USER_JOIN, false
      return resp.send(false)
    
    user.room = roomid
    sails.sockets.broadcast(room, ROOM_EVENT_NAMES.USER_JOIN, user, req.socket)
    joinRoom(user, roomid)

    sails.sockets.emit socketId, ROOM_SUCCESS_EVENT_NAMES.USER_JOIN, true
    resp.send(true)

exports.leave = (req, resp)=>
  room = req.param('roomid')
  sails.sockets.leave(req.socket, room)
  socketId = sails.sockets.id(req.socket)
  user = req.user.chatJSON()
  user.room = room
  if !user
    sails.sockets.emit socketId, ROOM_ERROR_EVENT_NAMES.USER_LEAVE, false
    return resp.send(false)

  sails.sockets.broadcast(room, ROOM_EVENT_NAMES.USER_LEAVE, user, req.socket)

  sails.sockets.emit socketId, ROOM_SUCCESS_EVENT_NAMES.USER_LEAVE, true
  resp.send(true)  

exports.getRooms = (req, resp)=>
  user = req.user
  RoomMember.find {user: user.id}, (e, rooms)->
    if e
      return resp.status(400).send(code: 5000, error: e)

    roomNames = []
    _.each rooms, (room)->
      roomNames.push room

    resp.send(roomNames)

exports.chat = (req, resp)=>
  roomId = req.param('roomid')
  message = req.param('message')
  socketId = sails.sockets.id(req.socket)
  user = req.user.chatJSON()
  if !user || !message
    sails.sockets.emit socketId, ROOM_ERROR_EVENT_NAMES.MESSAGE, false
    return resp.send(false)

  Room.findOne {id: roomId}, (e, room)->
    if e || !room || !user.id
      sails.sockets.emit socketId, ROOM_ERROR_EVENT_NAMES.MESSAGE, false
      return resp.send(false)
    data =
      room: room.id
      sender: user.id
      message: req.param('message')
      kind: room.kind

    Chat.create data, (e, xc)->
      sails.log.info e
      sails.log.info xc
      
      xc.sender = user
      sails.sockets.broadcast(roomId, ROOM_EVENT_NAMES.MESSAGE, xc, req.socket)

      sails.sockets.emit socketId, ROOM_SUCCESS_EVENT_NAMES.MESSAGE, xc
      resp.send(xc)

exports.messages = (req, resp)=>
  roomId = req.param('roomid')

  user = req.user.chatJSON()
  if !user
    return resp.send(false)
    
  page = req.param('page') || 1
  limit = req.param('limit') || 20
  if ! user || ! user.id
    return resp.send(false)

  RoomMember.findOne {room: roomId, user: user.id}, (e, roomMember)->
    if e || !roomMember
      return resp.send(false)
    Chat.find({room: roomId})
    .sort({ createdAt: 'desc' })
    .paginate({page: page, limit: limit})
    .populate('sender')
    .exec (e, results)->
      if e
        return resp.send(false)
      _.each results, (msg)->
        msg.sender = msg.sender.chatJSON()

      resp.send(results)


exports.onlines = (req, resp)=>
  roomId = req.param('roomid')
  socketIds = sails.sockets.subscribers(roomId)
  socketId = sails.sockets.id(req.socket)
  user = req.user.chatJSON()
  if !user
    return resp.send(false)
  UserSocket.find socketId: socketIds, (e, usrs)->
    if e
      return resp.send([])
    userIds = []
    users = []
    _.each usrs, (usr)->
      if userIds.indexOf(usr.id) < 0
        users.push usr.chatJSON()
        userIds.push(usr.id)

    resp.send(users)

  