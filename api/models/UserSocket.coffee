# use in future
module.exports =

  attributes:
    user:
      model: 'user'

    userNickname:
      type: 'string'

    userAvatarUrl:
      type: 'string'

    userDob:
      type: 'datetime'

    expiredAt:
      type: 'datetime'
    
    socketId:
      type: 'string'
      required: true
      unique: true
    
    chatJSON: ()->
      obj = this.toObject()
      ojs = 
        id: obj.user
        nickname: obj.userNickname
        fullname: obj.userNickname
        avatar_url: obj.userAvatarUrl
        onlineStatus: 'ONLINE'
      ojs
