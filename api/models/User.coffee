 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

ONLINE_STATUSES =
  ONLINE: 'ONLINE'
  BUSY: 'BUSY'
  AWAY: 'AWAY'
  INVISIBLE: 'INVISIBLE'
  OFFLINE: 'OFFLINE'

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  ONLINE_STATUSES: ONLINE_STATUSES
  attributes:
    # ---------------------#
    # store web controls  #
    # ------------------- #
    webId:
      type: 'string'
      unique: true
      required: true

    email:
      type: 'email'
      index: true
      email: true

    fullname:
      type: 'string'
      required: true

    dob:
      type: 'date'

    nickname:
      type: 'string'
      defaultsTo: ''
      maxLength: 50
      index: true

    avatar_url:
      type: 'string'

    package:
      type: 'string'
      # required: true

    cellphone:
      type: 'string'

    webSyncedAt:
      type: 'datetime'
      required: true

    onlineStatus:
      type: 'string'
      defaultsTo: ONLINE_STATUSES.OFFLINE

    token:
      type: 'string'
      index: true
      # unique: true

    tokenExpireAt:
      type: 'datetime'

    webToken:
      type: 'string'
      index: true
      
    fbUid:
      type: 'string'
      # uuid: true
      # unique: true 
    fbUrl:
      type: 'string'

    ggUid:
      type: 'string'

    handle:
      type: 'string'

    fbFriends:
      type: 'array'

    gender:
      type: 'string'

    # exp on global
    exp: 
      type: 'float'
      defaultsTo: 0.0

    level:
      type: 'integer'
      defaultsTo: 1

    cleverExp:
      type: 'float'
      defaultsTo: 0.0

    cleverLvl:
      type: 'integer'
      defaultsTo: 1
      
    exactExp:
      type: 'float'
      defaultsTo: 0.0

    exactLvl:
      type: 'integer'
      defaultsTo: 1
      
    logicExp:
      type: 'float'
      defaultsTo: 0.0

    logicLvl:
      type: 'integer'
      defaultsTo: 1
      
    naturalExp:
      type: 'float'
      defaultsTo: 0.0

    naturalLvl:
      type: 'integer'
      defaultsTo: 1
      
    socialExp:
      type: 'float'
      defaultsTo: 0.0      
    
    socialLvl:
      type: 'integer'
      defaultsTo: 1
      
    langExp:
      type: 'float'
      defaultsTo: 0.0
    
    langLvl:
      type: 'integer'
      defaultsTo: 1
    
    memoryExp:
      type: 'float'
      defaultsTo: 0.0
    
    memoryLvl:
      type: 'integer'
      defaultsTo: 1
      
    observationExp:
      type: 'float'
      defaultsTo: 0.0
    
    observationLvl:
      type: 'integer'
      defaultsTo: 1
      
    judgementExp:
      type: 'integer'
      defaultsTo: 0.0

    judgementLvl:
      type: 'integer'
      defaultsTo: 1
    
    targetedChallenge:
      collection: 'Challenge'
      via: 'target'
        
    # store star and money
    starMoney:
      type: 'integer'
      defaultsTo: 0
    rubyMoney:
      type: 'integer'
      defaultsTo: 0    
    energy:
      type: 'integer'
      defaultsTo: 480

    socketId:
      type: 'string'

    # { gamecode: { win, lose, rate, lastPlayed } }
    rateOnline:
      type: 'json'
      defaultsTo: {}

    publicJSON: () ->
      obj = this.toObject()
      ojs = 
        id: obj.id
        fullname: obj.fullname
        nickname: obj.nickname
        avatar_url: obj.avatar_url
        gender: obj.gender
        dob: obj.dob
        level: (obj.level || 1)
      ojs

    chatJSON: () ->
      obj = this.toObject()
      ojs = 
        id: obj.id
        nickname: obj.nickname
        fullname: obj.fullname
        avatar_url: obj.avatar_url
        gender: obj.gender
        onlineStatus: obj.onlineStatus
      ojs

    mathRoomJSON: () ->      
      return {
        id: this.id
        nickname: this.nickname
        avatar_url: this.avatar_url
        level: (this.level || 1)
      }

    incStarMoney: (star, cb) ->
      obj = this.toObject()
      newMoney = (obj.starMoney||0) + (star||0)
      User.update obj.id, {starMoney: newMoney}, (e, me) ->
        if e
          return cb(e, null)
        cb(null, me)

    descStarMoney: (star, cb) ->
      obj = this.toObject()
      newMoney = (obj.starMoney||0) - (star||0)
      if newMoney < 0
        newMoney = 0
      User.update obj.id, {starMoney: newMoney}, (e, me) ->
        if e
          return cb(e, null)
        cb(null, me)
