_ = require('lodash')

exports.listNotification = (params, cb)=>
  
  if !params.gameCode
    return cb({code: 5067, error: 'missing game code'})
  
  if params.category && !NoteMessage.NOTIFY_CATEGORIES[params.category]
    return cb({code: 5068, error: 'category is not valid'})

  Game.findOne code: params.gameCode, (e, game)->
    if e || !game
      return cb({code: 5033, error: 'not found game'})

    page = params.page || 1
    limit = params.limit || 20

    cond =
      user: params.user.id
      gameCode: game.code
      userStatus: 
        '!': NoteMessage.USER_STATUSES.CLOSE

    if params.category
      cond.category = params.category

    NoteMessage.find cond
    .sort({createdAt: 'desc'})
    .paginate({page: page, limit: limit})
    .exec (e, notes)->
      if e
        sails.log.error "[NotificationService.listNotification] ERROR: ... #{JSON.stringify(e)}"
        return cb({code: 5000, error: e})
      
      return cb(null, notes)

# user | gamecode | category | title | content | imageUrl | sound | badge | extends | days
exports.createNotification = (params, cb)=>

  if !params.gameCode
    return cb({code: 5067, error: 'missing game code', log: "[NotificationService.createNotification] ERROR: Missing game code"})

  if !params.category || !NoteMessage.NOTIFY_CATEGORIES[params.category]
    return cb({code: 5068, error: 'category is not valid', log: "[NotificationService.createNotification] ERROR: Invalid category"})

  if !params.title
    return cb({code: 5069, error: 'title is not valid', log: "[NotificationService.createNotification] ERROR: Invalid title"})

  if !params.content
    return cb({code: 5070, error: 'content is not valid', log: "[NotificationService.createNotification] ERROR: Invalid content"})

  try
    if typeof params.extends == 'string'
      params.extends = JSON.parse(params.extends || '{}')
    else
      params.extends = params.extends || {}
  catch
    return cb({code: 5071, error: 'extends parameter is invalid', log: "[NotificationService.createNotification] ERROR: Invalid extends"})

  Game.findOne code: params.gameCode, (err, game)->
    if err || !game
      return cb({code: 5033, error: 'not found game', log: "[NotificationService.createNotification] ERROR: Invalid game code"})

    data =
      user: params.user?.id || params.user
      gameCode: game.code
      category: params.category
      title: params.title
      content: params.content
      userStatus: NoteMessage.USER_STATUSES.NEW
      imageUrl: params.imageUrl
      expiredAt: params.expiredAt
      sound: params.sound || ''
      badge: (params.badge || 1)
      extends: params.extends

    # Insert to data and get current note
    NoteMessage.create data, (err, note)->
      if err
        return cb({code: 5000, error: "Could not process", log: "[NotificationService.createNotification] ERROR: ... #{JSON.stringify(e)}"})

      # Send message to user
      data.id = note.id
      PushNotificationService.pushNote data, (err, rst)->
        if err
          return sails.log.info err
        sails.log.info rst
      
      return cb(null, note)


exports.readNotification = (params, cb)=>
  if !params.noteid
    return cb({code: 5072, error: 'missing note id'})

  NoteMessage.findOne {user: params.user.id, id: params.noteid}, (e, note)->
    if e || !note
      sails.log.error "[NotificationService.readNotification] ERROR: ... #{JSON.stringify(e)}"
      return cb({code: 5073, error: 'could not found message'})
    
    note.userStatus = NoteMessage.USER_STATUSES.READ
    note.save (e, note)->
      if e
        sails.log.error "[NotificationService.readNotification] ERROR: ... #{JSON.stringify(e)}"
        return cb({code: 5074, error: 'cannot mark message as read'})

      return cb(null, note)


exports.removeNotification = (params, cb)=>
  if !params.noteid
    return cb({code: 5072, error: 'missing note id'})

  NoteMessage.findOne {user: params.user.id, id: params.noteid}, (e, note)->
    if e || !note
      sails.log.error "[NotificationService.readNotification] ERROR: ... #{JSON.stringify(e)}"
      return cb({code: 5073, error: 'could not found message'})
    
    note.userStatus = NoteMessage.USER_STATUSES.CLOSE
    note.save (e, note)->
      if e
        sails.log.error "[NotificationService.readNotification] ERROR: ... #{JSON.stringify(e)}"
        return cb({code: 5075, error: 'cannot remove message'})

      return cb(null, note)


exports.getConfigList = (params, cb)=>  
  NoteMessageConfig.find {user: params.user.id}, (e, configs)->
    if e
      return cb({code: 5076, error: 'could not get config'})

    _.each NoteMessage.NOTIFY_CATEGORIES, (value, c)->
      category = _.find configs, {category: c}
      if !category
        configs.push 
          category: c
          isActive: true

    return cb(null, configs)


exports.getConfig = (params, cb)=>
  if !NoteMessage.NOTIFY_CATEGORIES[params.category]
    return cb(false)

  userId = params.user?.id || params.user
  NoteMessageConfig.findOne {user: userId, category: params.category}, (e, config)->
    if e
      sails.log.error "[NotificationService.getConfig] ERROR: ... #{JSON.stringify(e)}"
      return cb(false)
    
    if !config
      return cb(true)    

    return cb(config.isActive)


exports.setConfig = (params, cb)=>
  if !params.isActive || !params.category
    return cb({Code: 5108, error: 'missing params'})

  if !NoteMessage.NOTIFY_CATEGORIES[params.category]
    return cb({code: 5068, error: 'category is not valid'})

  NoteMessageConfig.findOne {user: params.user.id, category: params.category}, (e, config)->
    if e
      sails.log.error "[NotificationService.setConfig] ERROR: ... #{JSON.stringify(e)}"
      return cb({code: 5000, error: 'error on find config'})

    if !config
      data = 
        user: params.user.id
        category: params.category
        isActive: params.isActive
      NoteMessageConfig.create data, (e, cf)->
        if e
          sails.log.error "[NotificationService.setConfig] ERROR: ... #{JSON.stringify(e)}"
          return cb({code: 5109, error: 'could not create config'})
        return cb(null, cf)

    else
      config.isActive = params.isActive
      config.save (e, cf)->
        if e
          sails.log.error "[NotificationService.setConfig] ERROR: ... #{JSON.stringify(e)}"
          return cb({code: 5110, error: 'could not update config'})

        return cb(null, cf)