module.exports =
  listRooms: (req, resp)->
    MathRoomService.listRooms(req, resp)

  listNahiRooms: (req, resp)->
    MathRoomService.listNahiRooms(req, resp)
    

  createRoom: (req, resp)->
    MathRoomService.createRoom(req, resp)

  watchRoom: (req, resp)->
    MathRoomService.watchRoom(req, resp)

  playRoom: (req, resp)->
    MathRoomService.playRoom(req, resp)

  autoJoin: (req, resp)->
    MathRoomService.autoJoin(req, resp)

  leaveRoom: (req, resp)->
    params = 
      roomid: req.param('roomid')
      user: req.user
      socket: req.socket

    MathRoomService.leaveRoom params, (e, room)-> 
      if e
        return resp.badRequest(e) 
      return resp.ok(true)

  jumpToWatcher: (req, resp)->
    params =
      user: req.user
      socket: req.socket
      roomid: req.param('roomid')

    MathRoomService.jumpToWatcher params, (e, done)->
      if e
        return resp.badRequest(e)
      return resp.ok(true)

  startRoom: (req, resp)->
    MathRoomService.startRoom(req, resp)

  score: (req, resp)->
    MathRoomMatchService.newScore(req, resp)

  misScore: (req, resp)->
    MathRoomMatchService.misScore(req, resp)

  backRoom: (req, resp)->
    MathRoomService.backRoom(req, resp)

  getTerms: (req, resp)->
    MathRoom.findOne {id: req.param('roomid')}, (e, room)->
      if e
        return resp.status(400).send({code: 5000, error: e}) 
      if !room
        return resp.status(400).send({code: 5055, error: "not found room"})

      terms = MathQuestionService.getTerms(room, 100)
      resp.status(200).send(terms)
