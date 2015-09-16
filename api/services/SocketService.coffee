require('date-utils')

exports.detectSocketConnect = (socketId)->
  sails.log.info "detectSocketConnect-------"
  sails.log.info socketId

exports.detectSocketDisconnect = (socketId)->
  sails.log.info "detectSocketDisconnect-------"
  sails.log.info socketId


exports.bindingSocket = (req)->
  socketId = sails.sockets.id(req.socket)
  user = req.user
  if user.socketId != socketId
    user.socketId = socketId
    user.save()
  UserSocket.findOne {socketId: socketId, user: user.id}, (e, userSocket)->
    if userSocket || e
      return false
    
    timeNow = new Date()
    timeNow.addMinutes(60)
    data = 
      socketId: socketId
      user: user.id
      userNickname: user.nickname
      userAvatarUrl: user.avatar_url
      userDob: user.dob
      expiredAt: timeNow

    UserSocket.create data, (e)->
