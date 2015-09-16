
isCategoryExist = (categoryId, done) ->
  if !categoryId?
    return done(null, false)

  GameCategory.findOne categoryId, (err, category) ->
    if err 
      return done({code: 5000, error: 'Could not process', log: "[GameCategoryService.isCategoryExist] ERROR: #{JSON.stringify(err)}"})
    if category
      return done(null, true)
    return done(null, false)

exports.list = (params, done) ->    
  if !params.sortBy || params.sortBy not in ['name', 'ordering', 'createdAt']
    params.sortBy = 'ordering'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'asc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition    
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10

  cond = {}
  if params.isActive?
    cond.isActive = params.isActive
  
  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)

  GameCategory.find cond
  .sort(sortCond)
  .exec (err, result)->
    if err
      return done({code: 5000, error: "could not process", log: "[GameCategoryService.list] ERROR: could not get Game category list ... #{JSON.stringify(err)}"})
    return done(null, result)

exports.add = (params, done)->
  if !params.name
    return done({code: 6203, error: "missing param name", log: "[GameCategoryService.add] ERROR: missing param name"})

  isCategoryExist params.parent, (err, isExist) ->
    if err
      return done(err)
    if params.parent && !isExist
      return done({code: 6204, error: "parent category is not exists", log: "[GameCategoryService.add] ERROR: parent category is not exists"})

    data = 
      parent: params.parent
      name: params.name
      ordering: params.ordering || 1
      isActive: if params.isActive? then params.isActive else true

    GameCategory.create data, (err, category) ->
      if err
        return done({code: 5000, error: "could not process", log: "[GameCategoryService.add] ERROR: could not add Game category ... #{JSON.stringify(err)}"})
      return done(null, category)

exports.update = (params, done)->
  if !params.id
    return done({code: 6205, error: "missing param id", log: "[GameCategoryService.update] ERROR: missing param name"})

  GameCategory.findOne params.id, (err, category) ->
    if err
      return done({code: 5000, error: "could not process", log: "[GameCategoryService.update] ERROR: could not process ... #{JSON.stringify(err)}"})
    if !category
      return done({code: 6206, error: "category is not exists", log: "[GameCategoryService.update] ERROR: category is not exists"})

    isCategoryExist params.parent, (err, isExist) ->
      if err
        return done(err)
      if !isExist
        return done({code: 6204, error: "parent category is not exists", log: "[GameCategoryService.update] ERROR: parent category is not exists"})

      category.parent = params.parent if params.parent
      category.name = params.name if params.name
      category.ordering = params.ordering if params.ordering
      category.isActive = params.isActive if params.isActive

      category.save (err, category) ->
        if err
          return done({code: 5000, error: "could not process", log: "[GameCategoryService.update] ERROR: could not update Game category ... #{JSON.stringify(err)}"})
        return done(null, category)
  
exports.remove = (params, done)->
  if !params.id
    return done({code: 6205, error: "missing params id", log: "[GameCategoryService.remove] ERROR: Missing params id"})

  GameCategory.destroy params.id, (err, deleted) ->
    if err
      return done({code: 5000, error: "could not process", log: "[GameCategoryService.remove] ERROR: could not remove Game category ... #{JSON.stringify(err)}"})            
    return done(null, 'ok')
   
exports.status = (params, done)->
  if !params.id
    return done({code: 6205, error: "missing params id", log: "[GameCategoryService.status] ERROR: Missing params id"})

  if !params.isActive?
    return done({code: 6207, error: 'missing param isActive', log: "[GameCategoryService.status] ERROR: Missing params isActive"})
  
  data =
    isActive: params.isActive

  GameCategory.update params.id, data, (err, category) ->
    if err
      return done({code: 5000, error: "could not process", log: "[GameCategoryService.status] ERROR: could not update status Game category ... #{JSON.stringify(err)}"})    
    return done(null, 'ok')
   