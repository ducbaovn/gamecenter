async = require('async')
_ = require('lodash')
OPERATORS = require('./MathScore').OPERATORS

MODES =
  EASY: 'EASY'
  MEDIUM: 'MEDIUM'
  HARD: 'HARD'

STATUSES = 
  OPENED: 'OPENED'
  LOCKED: 'LOCKED'
  DISABLE: 'DISABLE'


getPlayers = (roomid, done) ->
  MathRoomPlayer.find {mathroom: roomid}
  .populate('user')
  .sort({ createdAt: 'asc' })
  .exec (err, players) ->
    if err 
      sails.log.info err
      return done([])

    async.map players, (player, cb) ->
      cb(null, player.mathRoomJSON(player.user))
    , (err, result) ->
      return done(result)
    
getViewers = (roomid, done) ->
  MathRoomViewer.find {mathroom: roomid}
  .populate('user')
  .sort({ createdAt: 'asc' })
  .exec (err, viewers) ->
    if err 
      sails.log.info err
      return done([])

    async.map viewers, (viewer, cb) ->
      cb(null, viewer.mathRoomJSON(viewer.user))
    , (err, result) ->
      return done(result)


module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  MODES: MODES
  STATUSES: STATUSES
  OPERATORS: OPERATORS
  attributes:
    status:
      type: 'string'
      defaultsTo: STATUSES.OPENED
      required: true
      enum: _.values(STATUSES)
    
    owner:
      model: 'user'

    name:
      type: 'string'
      required: true

    hasPassword:
      type: 'boolean'
      defaultsTo: false
      required: true

    password:
      type: 'string'
      defaultsTo: ''

    mode:
      type: 'string'
      enum: _.values(MODES)
      defaultsTo: MODES.MEDIUM
      required: true
      
    operator:
      type: 'string'
      required: true
      enum: OPERATORS

    minLevel:
      type: 'integer'
      defaultsTo: 1
      required: true
      min: 1
      max: 99

    # seconds
    timeLimit:
      type: 'integer'
      required: true

    teamLimit:
      type: 'integer'
      required: true
      min: 2
      max: 100

    memberPerTeam:
      type: 'integer'
      required: true
      min: 1
      max: 100

    starPerMember:
      type: 'integer'
      required: true
      min: 0

    viewers:
      collection: 'mathroomviewer'
      via: 'mathroom'

    players:
      collection: 'mathroomplayer'
      via: 'mathroom'

    nahiRoom:
      type: 'boolean'
      defaultsTo: false

    # [
    #   {
    #     itemCode: 'ENS05'
    #     rank: 1
    #   }
    # ]
    winItems: 
      type: 'array'

    toJSON: () ->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.password
      obj

    publicJSON: () ->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.password
      delete obj.players
      delete obj.viewers
      delete obj.winItems
      obj

    getPlayers: (done) ->
      getPlayers(this.id, done)
        
    getViewers: (done) ->
      getViewers(this.id, done)
    
    getPlayersAndViewers: (done) ->
      roomid = this.id
      getPlayers roomid, (players) ->
        getViewers roomid, (viewers) ->       
          return done(players, viewers)

    isUserExistOnRoom: (user, done) ->
      cond =
        user: user.id
        mathroom: this.id
      MathRoomPlayer.findOne cond, (err, player) ->
        if err 
          return done({code: 5000, error: err})
        if player
          return done(null, true)

        MathRoomViewer.findOne cond, (err, viewer) ->
          if err 
            return done({code: 5000, error: err})
          if viewer
            return done(null, true)
          return done(null, false)

  updateUpdatedAt: (roomid, done) ->
    timeNow = new Date()
    MathRoom.update {id: roomid}, {updatedAt: timeNow}, (err) ->
      sails.log.info err if err
      done()