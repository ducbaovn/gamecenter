_ = require('lodash')
ObjectId = require('mongodb').ObjectID

checkGameCode = (gamecode, cb) ->
  Game.findOne code: gamecode, (err, game) ->
    if err
      sails.log.error 'find game fail'
      return cb({code: 5000, error: err}, null)
    if game
      return cb({code: 5135, error: 'game code is existed'}, null)
    cb(null)

checkGameName = (gamename, cb) ->
  Game.findOne name: gamename, (err, game) ->
    if err
      sails.log.error 'find game fail'
      return cb({code: 5000, error: err}, null)
    if game
      return cb({code: 5136, error: 'game name is existed'}, null)
    cb(null)

checkParent = (parentGameCode, cb) ->
  Game.findOne code: parentGameCode, (err, game) ->
    if err || !game
      sails.log.error 'find game parent fail'
      return cb({code: 5000, error: 'cannot find parent game'}, null)
    cb(null)    

exports.create = (params, done) =>
  async.series [
    (cb) ->
      checkGameCode params.code, cb
    ,
    (cb) ->
      checkGameName params.name, cb
    ,
    (cb) ->
      if params.parent
        checkParent params.parent, cb
      else
        cb(null)

    , (cb)->
      if params.moneyItem
        Item.findOne params.moneyItem, (err, item)->
          if err
            sails.log.error err
            return cb({code: 5000, error: err}, null)
          if !item
            sails.log.error 'not found item'
            return cb({code: 5090, error: 'not found item'}, null)
          
          cb(null)
      else
        cb(null)

  ], (e, results) ->
    if e
      return done(e)

    data =
      category: params.category
      code: params.code
      name: params.name
      description: params.description || ''
      icon: params.icon
      cover: params.cover
      packageUrl: params.packageUrl
      packageId: params.packageId
      parent: [params.parent] || []
      ordering: params.ordering || 1
      isActive: if params.isActive? then params.isActive else true
      naturalExpPreset: params.naturalExpPreset || 0
      socialExpPreset: params.socialExpPreset || 0
      langExpPreset: params.langExpPreset || 0
      moneyItem: params.moneyItem || null

    Game.create data, (err, game) ->                                                                                                                                            
      if err
        sails.log.error 'create game fail'
        return done({code: 5000, error: err}, null)
      if !game
        sails.log.error 'could not create game'
        return done({code: 5137, error: "could not create game"}, null)
      return done(null, game)

exports.update = (params, done) ->
  data = {}

  async.parallel [
    (cb) ->
      if params.code
        checkGameCode params.code, cb
        data.code = params.code
      else cb(null)
    ,
    (cb) ->
      if params.name
        checkGameName params.name, cb
        data.name = params.name
      else cb(null)
    ,
    (cb) ->
      if params.parent
        checkParent params.parent, cb
        data.parent = [params.parent]
      else cb(null)
    ,
    (cb) ->
      if params.moneyItem?
        if _.isBoolean(params.moneyItem) && !params.moneyItem 
          data.moneyItem = null
          return cb(null)
          
        Item.findOne params.moneyItem, (err, item) ->
          if err
            sails.log.error err
            return cb({code: 5000, error: err}, null)
          if !item
            sails.log.error 'not found item'
            return cb({code: 5090, error: 'not found item'}, null)          
          data.moneyItem = params.moneyItem

          cb(null)
      else cb(null)

  ], (e, result) ->
    if e
      return done(e)

    data.category = params.category if params.category
    data.description = params.description if params.description
    data.icon = params.icon if params.icon
    data.cover = params.cover if params.cover
    data.packageUrl = params.packageUrl if params.packageUrl
    data.packageId = params.packageId if params.packageId
    data.ordering = params.ordering if params.ordering
    data.isActive = params.isActive if params.isActive?
    data.naturalExpPreset = params.naturalExpPreset if params.naturalExpPreset
    data.socialExpPreset = params.socialExpPreset if params.socialExpPreset
    data.langExpPreset = params.langExpPreset if params.langExpPreset

    Game.update params.id, data, (err, result) ->
      if err
        return done({code: 5000, error: err}, null)
      if !result
        return done({code: 5139, error: "could not update game"}, null)

      return done(null, result)

exports.delete = (params, done) =>
  elements = [
    Banner,
    Bucket,
    Challenge,
    Item,
    NoteMessage,
    Playing
  ]

  Game.findOne params.id, (err, game) -> 
    if err
      return done({code: 5000, error: err}, null)    
    if !game
      return done({code: 5033, error: 'could not found game'})

    gamecode = game.code

    async.eachSeries elements, (element, cb) ->
      element.findOne gameCode: gameCode, (err, result) ->
        if err
          return cb({code: 5000, error: err}, null)
        if result
          return cb({code: 5138, error: 'could not remove game'}, null)
        return cb(null, result)
    , (err, result) ->
      if err
        sails.log.info "remove game fails #{JSON.stringify(err)}"
        return done(err)

      Game.findOne parent: [gameCode], (err, game) ->
        if err
          return cb({code: 5000, error: err}, null)
        if game
          return cb({code: 5138, error: 'could not remove game'}, null)

        Game.destroy params.id, (err, result) ->
          if err
            sails.log.error "remove game fails #{e}"
            return done({code: 5000, error: err}, null)

          return done(null, result)

exports.active = (params, done) ->
  data =
    isActive: params.isActive

  Game.update params.id, data, (err, result) ->
    if err
      return done({code: 5000, error: err}, null)
    if !result
      return done({code: 5139, error: "could not update game"}, null)

    return done(null, result)

exports.list = (params, done) ->
  pattern = /[^0-9a-f]/
  if params.category? && (params.category.length != 24 || pattern.test(params.category))
    return done({code: 6202, error: 'category must be 24 hex characters'}, null)        

  # build sort condition
  if !params.sortBy || params.sortBy not in ['code', 'name', 'ordering', 'createdAt']
    params.sortBy = 'ordering'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'asc'
  sortCond = {}
  sortCond[params.sortBy] = (if params.sortOrder == 'asc' then 1 else -1)

  # build condition
  cond = {}
  if params.parent? && params.parent.length > 0
    cond.parent = {$in: [params.parent]}  
  if params.isActive?
    cond.isActive = params.isActive
  if params.category
    cond.category = ObjectId(params.category)
  if params.filter
    cond.$or = [
      code:
        $regex: params.filter
        $options: 'i'
    ,
      name:
        $regex: params.filter
        $options: 'i'
    ]

  # select fields
  select =
    id: true
    name: true
    code: true
    description: true
    icon: true
    cover: true
    packageUrl: true
    packageId: true

  Game.native (err, collection) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[GameService.list] ERROR: Could not get Game list... #{err}"})

    query = collection.find(cond, select).sort(sortCond)

    # paging    
    page = parseInt(params.page) || 1
    limit = parseInt(params.limit) || 20
    skip = (page - 1) * limit
    if limit > 0
      query = query.skip(skip).limit(limit)

    query.toArray (err, games) ->
      if err
        return done({code: 5000, error: 'Could not process', log: "[GameService.list] ERROR: Could not get Game list... #{err}"})

      async.map games, (game, cb) ->  
        game.id = game._id.toString()
        delete game._id
        return cb(null, game)
      , (err, list) ->
        return done(null, list)
