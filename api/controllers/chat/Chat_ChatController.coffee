_ = require('lodash')

TRIGGER_NAMES =
  AUTHORIZED: 'CHAT:AUTHORIZED'

TRIGGER_ERROR_NAMES =
  AUTHORIZED: 'CHAT_ERROR:AUTHORIZED'

module.exports =
  # authenticate
  auth: (req, resp)=>
    token = req.param('token')
    socketId = sails.sockets.id(req.socket)

    sails.sockets.emit socketId, TRIGGER_NAMES.AUTHORIZED, {msg: req.user.chatJSON()}
    return resp.send(req.user.publicJSON())

  # friends online
  onlines: (req, resp)=>
    socketId = sails.sockets.id(req.socket)
    user = req.user

    if !user
      return resp.send(false)

    User.find {}, (e, users)->
      if e
        return resp.send(false)
      usrs = []
      _.each users, (usr)->
        usrs.push usr.chatJSON()
      resp.send(usrs)


  peerChat: (req, resp)=>
    PeerRoomService.chat(req, resp)

  messages: (req, resp)=>
    PeerRoomService.messages(req, resp)