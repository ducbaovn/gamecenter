
exports.list = (params, done) ->  
  # build sort condition
  if !params.sortBy || params.sortBy not in ['category']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition  
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10
  
  cond = {}
  if params.category
    cond.category = params.category
  if params.id
    cond.id = params.id
  if params.filter
    cond.$or = [
      code:
        'contains': params.filter
    ,
      name:
        'contains': params.filter
    ]
  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)
    
  Image.find cond
  .sort(sortCond)
  .populate('category')
  .exec (err, images)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.list] ERROR: could not get Image list ... #{JSON.stringify(err)}"})

    Image.count cond, (err, total)->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.list] ERROR: could not count Image list ... #{JSON.stringify(err)}"})

      return done(null, {result: images, total: total})

exports.add = (params, done)->
  if !params.images
    return done({code: 6009, error: 'Missing required params images', log: '[BrainAdmin_ImageService.add] ERROR: Missing required params images'})
  if typeof params.images != 'object'
    try
      params.images = JSON.parse params.images
    catch e
      return done({code: 6002, error: 'Could not JSON.parse params.images', log: '[BrainAdmin_ImageService.add] ERROR: Could not JSON.parse params.images... #{JSON.stringify(e)}'})
  for image in params.images
    if !image.imageUrl || !image.category
      return done({code: 6010, error: 'Missing required params (imageUrl, category)', log: '[BrainAdmin_ImageService.add] ERROR: Missing required params (imageUrl, category)'})
    if image.extends
      image.extends =
        imageUrl: image.extends
    else delete image.extends
  
  if params.images.length != _.uniq(params.images, 'imageUrl').length
    return done({code: 6008, error: 'Image is duplicated', log: '[BrainAdmin_ImageService.add] ERROR: Image is duplicated'})
  ImageCategory.findOne id: params.images[0].category, (err, category)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.add] ERROR: could not get ImageCategory... #{JSON.stringify(err)}"})
    if !category
      return done({code: 6011, error: 'Category is not found', log: '[BrainAdmin_ImageService.add] ERROR: Category is not found'})  
    Image.create params.images, (err, newImages) ->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.add] ERROR: could not create Image... #{JSON.stringify(err)}"})
      return done(null, newImages)

exports.remove = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_ImageService.remove] ERROR: Missing params id"})
  Image.findOne id: params.id, (err, image) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not get Image... #{JSON.stringify(err)}"})
    if image
      ImageCategory.findOne id: image.category
      .populate('game')
      .exec (err, category)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not find ImageCategory... #{JSON.stringify(err)}"})
        switch category.game.code
          when Game.VISIBLE_APIS.DUNG_NOI then DungNoiQuestion.findOne [{image: image.id}, {rightAnswer: image.id}], (err, question)->
            if err
              return done(err)
            if question?
              return done({code: 6058, error: "Could not delete!! This image has been used in some quiz", log: "[BrainAdmin_ImageService.remove] ERROR: Could not delete!! This image has been used in some quiz"})
            Image.destroy id: params.id, (err, deleted) ->
              if err
                return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not remove Image... #{JSON.stringify(err)}"})
              return done(null, {success: 'Deleted Image success'})

          when Game.VISIBLE_APIS.TIM_BONG then TimBongAnswer.findOne [{image: image.id}, {shadowImage: image.id}], (err, answer)->
            if err
              return done(err)
            if answer?
              return done({code: 6058, error: "Could not delete!! This image has been used in some quiz", log: "[BrainAdmin_ImageService.remove] ERROR: Could not delete!! This image has been used in some quiz"})
            Image.destroy id: params.id, (err, deleted) ->
              if err
                return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not remove Image... #{JSON.stringify(err)}"})
              return done(null, {success: 'Deleted Image success'})

          when Game.VISIBLE_APIS.NHANH_MAT then async.parallel [
            (cb)->
              NhanhMatBatHinhQuiz.findOne question: category.id, (err, quiz)->
                if err
                  return cb({code: 5000, error: "Could not process", log: "[BrainAdmin_ImageService.remove] ERROR: Could not find NhanhMatBatHinhQuiz... #{err}"}, null)
                if quiz?
                  return cb({code: 6058, error: "Could not delete!! This image has been used in some quiz", log: "[BrainAdmin_ImageService.remove] ERROR: Could not delete!! This image has been used in some quiz"})
                return cb(null, 'ok')
            (cb)->
              NhanhMatBatHinhAnswerItem.findOne category: category.id, (err, answerItem)->
                if err
                  return cb({code: 5000, error: "Could not process", log: "[BrainAdmin_ImageService.remove] ERROR: Could not find NhanhMatBatHinhAnswerItem... #{err}"}, null)
                if answerItem?
                  return cb({code: 6058, error: "Could not delete!! This image has been used in some quiz", log: "[BrainAdmin_ImageService.remove] ERROR: Could not delete!! This image has been used in some quiz"})
                return cb(null, 'ok')
          ], (err, ok)->
            if err
              return done(err)
            Image.destroy id: params.id, (err, deleted) ->
              if err
                return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not remove Image... #{JSON.stringify(err)}"})
              return done(null, {success: 'Deleted Image success'})


          when Game.VISIBLE_APIS.PHAN_BIET then PhanBietHinhChuAnswer.findOne [{image: image.id}, {textImage: image.id}], (err, answer)->
            if err
              return done(err)
            if answer?
              return done({code: 6058, error: "Could not delete!! This image has been used in some quiz", log: "[BrainAdmin_ImageService.remove] ERROR: Could not delete!! This image has been used in some quiz"})
            Image.destroy id: params.id, (err, deleted) ->
              if err
                return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not remove Image... #{JSON.stringify(err)}"})
              return done(null, {success: 'Deleted Image success'})

          when Game.VISIBLE_APIS.NHANH_TAY then Image.destroy id: params.id, (err, deleted) ->
              if err
                return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.remove] ERROR: could not remove Image... #{JSON.stringify(err)}"})
              return done(null, {success: 'Deleted Image success'})

          else 
            return done({code: 6059, error: "Invalid Game Code", log: "[BrainTermService.getTerms] ERROR: Invalid Game Code"})
            
    else
      return done({code: 6012, err: 'This Image does not exist', log: "[BrainAdmin_ImageService.remove] ERROR: This Image does not exist"})

exports.update = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_ImageService.update] ERROR: Missing params id"})
  Image.findOne id: params.id, (err, image) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.update] ERROR: could not get Image... #{JSON.stringify(err)}"})
    if image
      if params.extends
        image.extends =
          imageUrl: params.extends
      else
        image.extends = null
      if params.name
        image.name = params.name
      if params.category
        image.category = params.category
      if params.imageUrl
        image.imageUrl = params.imageUrl
      cond = {}
      cond.id = '!': image.id
      cond.category = image.category
      cond.$or = [
        name: image.name
      ,
        imageUrl: image.imageUrl
      ]
      Image.findOne cond, (err, existImage)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.update] ERROR: could not get Image... #{JSON.stringify(err)}"})     
        if existImage
          return done({code: 6013, error: 'Name or ImageURL is existed', log: "[BrainAdmin_ImageService.update] ERROR: Name or ImageURL is existed"})
        image.save (err, newImage)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_ImageService.update] ERROR: could not get Image... #{JSON.stringify(err)}"})
          return done(null, newImage)
    else return done({code: 6012, error: 'This Image does not exist', log: "[BrainAdmin_ImageService.update] ERROR: This Image does not exist"})
