_ = require('lodash')

module.exports =
  onlines: (req, resp)=>
    RoomService.onlines(req, resp)

  rooms: (req, resp)=>
    Room.find {kind: Room.KINDS.PUBLIC}, (err, rooms)->
      if err
        resp.status(400).send(code: 5000, error: err)
      resp.send(rooms)

  join: (req, resp)=>
    RoomService.join(req, resp)

  leave: (req, resp)=>
    RoomService.leave(req, resp)

  chat: (req, resp)=>
    RoomService.chat(req, resp)

  messages: (req, resp)=>
    RoomService.messages(req, resp)
