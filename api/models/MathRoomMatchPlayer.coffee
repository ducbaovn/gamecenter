_ = require('lodash')

module.exports =
  connection: 'gcRedis'
  schema: true
  autoCreatedAt: false
  autoUpdatedAt: false
  attributes:    
    mathroommatch:
      model: 'mathroommatch'
      required: true

    user:
      model: 'user'
      required: true

    team:
      type: 'integer'
  
    position:
      type: 'integer'
  
    score:
      type: 'integer'

    updatedAt:
      type: 'datetime'

    socketId:
      type: 'string'

    endTime:
      type: 'datetime'

    mathRoomJSON: (userObj) ->      
      obj = 
        id: userObj.id
        nickname: userObj.nickname
        avatar_url: userObj.avatar_url
        level: (userObj.level || 1)
        team: this.team
        position: this.position
        ready: true
        socketId: this.socketId
      return obj

    playingJSON: () ->
      return {
        id: this.user
        team: this.team
        position: this.position
        score: this.score
        socketId: this.socketId
      }

    finishGameJSON: () ->
      return {
        id: this.user
        position: this.position
        score: this.score
        socketId: this.socketId
      }