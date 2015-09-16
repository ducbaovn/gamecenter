_ = require('lodash')

STATUSES =
  PENDING: 'PENDING'
  PLAYING: 'PLAYING'
  FINISHED: 'FINISHED'

FEE = 0.1

getPlayers = (matchId, done) ->
  MathRoomMatchPlayer.find {mathroommatch: matchId}, (err, matchPlayers) ->
    if err
      return done([])
      
    matchPlayers = _.sortByOrder(matchPlayers, ['score', 'updatedAt'], [false, true])

    return done(matchPlayers)

module.exports =
  connection: 'gcRedis'
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  STATUSES: STATUSES
  FEE: FEE
  
  attributes:
    owner:
      model: 'user'
    
    mathroom:
      model: 'mathroom'
      required: true

    # room name
    name:
      type: 'string'

    mode:
      type: 'string'
    
    minLevel:
      type: 'integer'
    
    timeLimit:
      type: 'integer'

    teamLimit:
      type: 'integer'

    memberPerTeam:
      type: 'integer'

    starPerMember:
      type: 'integer'

    # start time
    startTime:
      type: 'datetime'

    # end time
    endTime:
      type: 'datetime'

    remainingTime:
      type: 'integer'

    nahiRoom:
      type: 'boolean'
      defaultsTo: false

    # [
    #   {
    #       item: itemObject
    #       rank
    #   }
    # ]
    winItems:
      type: 'array'

    status:
      type: 'string'
      required: _.values(STATUSES)
      defaultsTo: STATUSES.PLAYING

    # [{
    #     "operator": "+",
    #     "aValue": 809,
    #     "bValue": 60,
    #     "result": 869,
    #     "result_1": 864,
    #     "result_2": 865
    # }]
    terms:
      type: 'array'

    # [
    #   {
    #     name: 'team1', 
    #     players: [
    #       {id: '1', name: ''}, 
    #       {id: '2', name: ''}
    #     ],
    #     rank: 1,
    #     score: 30000
    #   }
    # ]
    playboards:
      type: 'array'

    getPlayers: (done) ->
      getPlayers(this.id, done)

    getPlayingPlayers: (done) ->
      getPlayers this.id, (matchPlayers) ->
        async.map matchPlayers, (matchPlayer, cb) ->
          cb(null, matchPlayer.playingJSON())
        , (err, result) ->
          return done(result)

    getMathRoomPlayers: (done) ->
      MathRoomMatchPlayer.find {mathroommatch: this.id}
      .populate('user')
      .exec (err, matchPlayers) ->
        if err 
          return done([])

        async.map matchPlayers, (matchPlayer, cb) ->
          cb(null, matchPlayer.mathRoomJSON(matchPlayer.user))
        , (err, result) ->
          return done(result)

    toPlayingJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.terms
      delete obj.mode
      delete obj.minLevel
      delete obj.timeLimit
      delete obj.teamLimit
      delete obj.memberPerTeam
      delete obj.starPerMember
      delete obj.playboards
      obj
      
    toTopboardJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.terms
      delete obj.mode
      delete obj.minLevel
      delete obj.timeLimit
      delete obj.teamLimit

      obj

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