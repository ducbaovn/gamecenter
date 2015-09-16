_ = require('lodash')

PEER_CHAT_EVENT_NAMES =
  USER_JOIN: 'CHAT:PEER:USER:JOIN'
  USER_LEAVE: 'CHAT:PEER:USER:LEAVE'
  MESSAGE: 'CHAT:PEER:MESSAGE'

PEER_CHAT_ERROR_EVENT_NAMES =
  USER_JOIN: 'CHAT_ERROR:PEER:USER:JOIN'
  USER_LEAVE: 'CHAT_ERROR:PEER:USER:LEAVE'
  MESSAGE: 'CHAT_ERROR:PEER:MESSAGE'

sendMessage = (req, resp, room)->
  socketId = sails.sockets.id(req.socket)
  message = req.param('message')

  data =
    sender: req.user.id
    room: room.id
    message: message
  Chat.create data, (e, chat)->
    if e || !chat?
      sails.sockets.emit socketId, PEER_CHAT_ERROR_EVENT_NAMES.MESSAGE, false
      return resp.send(false)
      
    chat.sender = req.user
    User.findOne id: req.receiverId, (e, receiver)->
      if receiver
        sails.sockets.emit receiver.socketId, PEER_CHAT_EVENT_NAMES.MESSAGE, chat

    sails.sockets.emit socketId, PEER_CHAT_EVENT_NAMES.MESSAGE, chat
    return resp.send(chat)

exports.chat = (req, resp)=>
  socketId = sails.sockets.id(req.socket)
  sender = req.user.chatJSON()
  if !sender
    sails.sockets.emit socketId, PEER_CHAT_ERROR_EVENT_NAMES.MESSAGE, false
    return resp.send(false)

  receiverId = req.param('userid')
  req.user = sender
  req.receiverId = receiverId

  cond = 
    or: [
      kind: Room.KINDS.PEER
      owner: sender.id
      target: receiverId
    , 
      kind: Room.KINDS.PEER
      owner: receiverId
      target: sender.id
    ]
  Room.findOne cond, (e, rm)->
    if e
      sails.sockets.emit socketId, PEER_CHAT_ERROR_EVENT_NAMES.MESSAGE, false
      return resp.send(false)

    if !rm
      data =
        kind: Room.KINDS.PEER
        owner: sender.id
        target: receiverId
      Room.create data, (e, room)->
        if e || !room
          sails.sockets.emit socketId, PEER_CHAT_ERROR_EVENT_NAMES.MESSAGE, false
          return resp.send(false)
        return sendMessage(req, resp, room)
      return
    sendMessage(req, resp, rm)



exports.messages = (req, resp)=>
  #socketId = sails.sockets.id(req.socket)
  sender = req.user.chatJSON()
  if !sender
    return resp.send(false)

  receiverId = req.param('userid')
  page = req.param('page') || 1
  limit = req.param('limit') || 20

  cond = 
    or: [
      kind: Room.KINDS.PEER
      owner: sender.id
      target: receiverId
    , 
      kind: Room.KINDS.PEER
      owner: receiverId
      target: sender.id
    ]

  Room.findOne cond, (e, room)->
    if e || !room
      return resp.send([])
    Chat.find({room: room.id})
    .sort({createdAt: 'desc'})
    .paginate({page: page, limit: limit})
    .populate('sender')
    .exec (e, messages)->
      if e
        return resp.send([])

      _.each messages, (msg)->
        msg.sender = msg.sender.chatJSON()
      resp.send(messages)
