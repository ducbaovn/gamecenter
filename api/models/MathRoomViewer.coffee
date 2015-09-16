_ = require('lodash')

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  attributes:    
    user:
      model: 'user'

    mathroom:
      model: 'mathroom'
  
    socketId:
      type: 'string'

    toJSON: () ->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj

    mathRoomJSON: (userObj) ->      
      obj = 
        id: userObj.id
        nickname: userObj.nickname
        avatar_url: userObj.avatar_url
        level: (userObj.level || 1)
        socketId: this.socketId
      return obj

  # Lifecycle Callbacks
  afterCreate: (value, next) ->
    MathRoom.updateUpdatedAt(value.mathroom, next)

  afterUpdate: (value, next) ->
    MathRoom.updateUpdatedAt(value.mathroom, next)

  afterDestroy: (values, next) ->
    if values[0]?
      MathRoom.updateUpdatedAt(values[0].mathroom, next)
    else
      next()
