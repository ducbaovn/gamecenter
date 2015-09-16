checkCategoryName = (params, done) ->
  if params.name
    cond =
      name: params.name
    cond.type = params.type if params.type
    StoresCategory.findOne cond, (err, ct) ->
      if err || ct
        return done(true)
      return done(false)
  else
    return done(null)

exports.listCategory = (params, done) ->
  if !params.sortBy || params.sortBy not in ['code', 'name']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10

  cond = {}

  if params.id
    cond.id  = params.id

  if params.name
    cond.name = params.name

  if params.type
    cond.type = params.type

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = (params.page - 1) * params.limit

  if params.isActive?
    cond.isActive = params.isActive

  StoresCategory.find cond
  .sort(sortCond)
  .exec (err, categorys)->
    if err
      return done({code: 5000, error: err, log: "[StoresService.listCategorys] ERROR: could not get category list ... #{JSON.stringify(err)}"})

    StoresCategory.count cond, (err1, total)->
      if err1
        return done({code: 5000, error: err1, log: "[StoresService.listCategorys] ERROR: could not count category list ... #{JSON.stringify(err1)}"})
      return done(total: total, result: categorys)

exports.addCategory = (params, done) ->
  if !params.name
    return done({code: 6104, error: 'Missing param name', log: "[StoresService.addCategorys] ERROR: Missing param name"})
  
  data =
    name: params.name

  if params.type
    data.type = params.type
  if params.imageUrl
    data.imageUrl = params.imageUrl

  StoresCategory.findOne data, (err, category) ->
    if err
      return done({code: 5000, error: err, log: "[StoresService.addCategorys] ERROR: #{JSON.stringify(err1)}"})
    if category
      return done({code: 6105, error: "Category name is existed", log: "[StoresService.addCategorys] ERROR: Category name is existed"})

    data.isActive = params.isActive if params.isActive?
    StoresCategory.create data, (err2, newCategory) ->
      if err2
        return done({code: 5000, error: err, log: "[StoresService.addCategorys] ERROR: #{JSON.stringify(err2)}"})
      return done(null, newCategory)

exports.updateCategory = (params, done) ->
  if !params.id
    return done({code: 6106, error: "Missing param id", log: "Missing param id"})
  StoresCategory.findOne params.id, (err, category) ->
    if err
      return done({code: 5000, error: err, log: "[StoresService.updateCategory] ERROR: #{JSON.stringify(err)}"})
    if !category
      return done({code: 6102, error: "could not found category", log: "[StoresService.removeCategory] ERROR: Could not found category"})

    checkCategoryName params, (result) ->
      if result
        return done({code: 6105, error: "category name is existed", log: "[StoresService.removeCategory] ERROR: Category name is existed"})
      
      category.name = params.name if result == false
      category.isActive = params.isActive if params.isActive?
      category.type = params.type if params.type

      category.save (err1, ct) ->
        if err1
          return done({code: 5000, error: err, log: "[StoresService.updateCategory] ERROR: #{JSON.stringify(err1)}"})
        return done(null, ct)


exports.removeCategory = (params, done) ->
  if !params.id
    return done({code: 6106, error: "Missing param id", log: "Missing param id"})
  StoresCategory.destroy id: params.id, (err, del) ->
    if err
      return done({code: 5000, error: err, log: "[StoresService.removeCategory] ERROR: #{JSON.stringify(err)}"})
    if del.length == 0
      return done({code: 6102, error: 'Could not find category', log: "[StoresService.removeCategory] ERROR: Could not find category..."})
    return done(null,success: 'ok')