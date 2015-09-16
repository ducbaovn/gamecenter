
exports.list = (params, done) ->  
  if !params.sortBy || params.sortBy not in ['name', 'code']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition  
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10
  
  cond = {}
  if params.id?
    cond.id = params.id
  if params.game?
    cond.game = params.game

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)

  ImageCategory.find cond
  .sort(sortCond)
  .populate('images')
  .populate('game')
  .exec (err, imageCategory)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.list] ERROR: could not get ImageCategory list ... #{JSON.stringify(err)}"})
    ImageCategory.count cond, (err, total)->
      if err 
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.list] ERROR: could not count ImageCategory list ... #{JSON.stringify(err)}"})
      return done(null, {result: imageCategory, total: total})

exports.add = (params, done)->
  if !params.imageCategories
    return done({code: 6001, error: 'Missing required params imageCategories', log: '[BrainAdmin_ImageCategoryService.add] ERROR: Missing required params imageCategories'})
  if typeof params.imageCategories != 'object'
    try
      params.imageCategories = JSON.parse params.imageCategories
    catch e
      return done({code: 6002, error: 'Could not JSON.parse params.images', log: '[BrainAdmin_ImageCategoryService.add] ERROR: Could not JSON.parse params.imageCategories... #{JSON.stringify(e)}'})
  for imageCategory in params.imageCategories
    if !imageCategory.code || !imageCategory.game || !imageCategory.name
      return done({code: 6003, error: 'Missing required params (code, game, name)', log: '[BrainAdmin_ImageCategoryService.add] ERROR: Missing required params (code, game, name)'})
  if _.uniq(params.imageCategories, 'name').length != params.imageCategories.length
    return done({code: 6004, error: 'Name is duplicated', log: "[BrainAdmin_ImageCategoryService.add] ERROR: Name is duplicated"})
  if _.uniq(params.imageCategories, 'code').length != params.imageCategories.length
    return done({code: 6005, error: 'Code is duplicated', log: "[BrainAdmin_ImageCategoryService.add] ERROR: Code is duplicated"})
  
  Game.findOne id: params.imageCategories[0].game, (err, game)->
    if err
      return done({code: 5000, error: 'could not process', log: "[BrainAdmin_ImageCategoryService.add] ERROR: could not find ImageCategory list ... #{JSON.stringify(err)}"})
    if !game
      return done({code: 6006, error: 'Game is not found', log: '[BrainAdmin_ImageCategoryService.add] ERROR: Game is not found'})
    async.each params.imageCategories, (category, cb)->
      cond = {}
      cond.$or = [
        name: category.name
        game: category.game
      ,
        code: category.code
      ]
      ImageCategory.findOne cond, (err, existCategory)->
        if err
          return cb({code: 5000, error: 'Could not process', log: '[BrainAdmin_ImageCategoryService.add] ERROR: Could not process'})
        if existCategory
          return cb()
        ImageCategory.create category, (err, newCategory) ->
          if err
            return cb({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.add] ERROR: could not create ImageCategory ... #{JSON.stringify(err)}"})
          return cb()
    , (err)->
      if err
        return done(err, null)
      return done(null, {success: 'Add Image Category success'})

exports.remove = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_ImageCategoryService.remove] ERROR: Missing params id"})
  ImageCategory.findOne id: params.id, (err, category) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.remove] ERROR: could not get ImageCategory ... #{JSON.stringify(err)}"})
    if category
      ImageCategory.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.remove] ERROR: could not remove ImageCategory ... #{JSON.stringify(err)}"})
        return done(null, {success: 'Deleted ImageCategory success'})
    else
      return done({code: 6007, err: 'This ImageCategory does not exist', log: "[BrainAdmin_ImageCategoryService.remove] ERROR: This ImageCategory does not exist"})

exports.update = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_ImageCategoryService.update] ERROR: Missing params id"})
  ImageCategory.findOne id: params.id
  .populate 'images'
  .exec (err, category) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.update] ERROR: could not get ImageCategory ... #{JSON.stringify(err)}"})
    if category
      if params.description
        category.description = params.description
      if params.name
        category.name = params.name
      if params.game
        category.game = params.game
      cond =
        name: category.name
        game: category.game
        id:
         '!': category.id
      ImageCategory.findOne cond, (err, existCat)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.update] ERROR: could not get ImageCategory ... #{JSON.stringify(err)}"})
        if existCat
          return done({code: 6004, error: "This name is existed", log: "[BrainAdmin_ImageCategoryService.update] ERROR: This name is existed"})
        if params.remove
          if typeof params.remove != 'object'
            try
              params.remove = JSON.parse params.remove
            catch
              return done({code: 6002, error: 'Could not JSON.parse params.remove', log: '[BrainAdmin_ImageCategoryService.update] ERROR: Could not JSON.parse params.remove'})
          category.images.remove(removeImage) for removeImage in params.remove
        params.add = params.add || []
        params.images = params.images || []
        if typeof params.add != 'object'
          try
            params.add = JSON.parse params.add
          catch
            return done({code: 6002, error: 'Could not JSON.parse params.add', log: '[BrainAdmin_ImageCategoryService.update] ERROR: Could not JSON.parse params.add'})
        if typeof params.images != 'object'
          try
            params.images = JSON.parse params.images
          catch
            return done({code: 6002, error: 'Could not JSON.parse params.images', log: '[BrainAdmin_ImageCategoryService.update] ERROR: Could not JSON.parse params.images'})
        newImages = params.images.concat(params.add)
        if _.uniq(newImages, 'imageUrl').length != newImages.length
          return done({code: 6008, error: 'Images are duplicated or existed', log: '[BrainAdmin_ImageCategoryService.update] ERRORL: Images are duplicated or existed'})
        category.images.add(params.add)
        category.save (err, newCategory)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageCategoryService.update] ERROR: could not update ImageCategory ... #{JSON.stringify(err)}"})
          if params.remove
            Image.destroy params.remove, (err)->
              if err
                sails.log.info "[BrainAdmin_ImageCategoryService.update] ERROR: could not remove Image... #{JSON.stringify(err)}"
          if params.images[0]        
            async.each params.images, (image, cb)->
              BrainAdmin_ImageService.update image, (err, newImage)->
                if err
                  return cb(err)
                return cb()
            , (err)->
              if err
                return done(err, null)
              BrainAdmin_ImageService.list category: category.id, (err, images)->
                if err
                  return done(err, null)
                newCategory.images = images
                return done(null, newCategory)
          else return done(null, newCategory)
    else return done({code: 6007, error: 'This ImageCategory does not exist', log: '[BrainAdmin_ImageCategoryService.update] ERROR: This ImageCategory does not exist'})
