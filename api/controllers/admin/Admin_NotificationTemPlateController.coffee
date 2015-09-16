module.exports =
  list: (req, resp) =>
    params = req.allParams()

    if !params.gameCode
      return resp.badRequest({code: 5067, error: 'missing game code'})
    if !params.category
      return resp.badRequest({code: 5141, error: 'missing category'})
    if !NotificationTemplate.NOTIFY_CATEGORIES[params.category]
      return resp.badRequest({code: 5068, error: 'category is not valid'})

    # build sort condition
    if !params.sortBy || params.sortBy not in ['title', 'isActive']
      params.sortBy = 'createdAt'
    if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
      params.sortOrder = 'desc'
    sortCond = {}
    sortCond[params.sortBy] = params.sortOrder

    # build condition   
    params.page = parseInt(params.page) || 1
    params.limit = parseInt(params.limit) || 10

    cond =
      gameCode: params.gameCode
      category: params.category

    NotificationTemplate.find cond
    .paginate {page: params.page, limit: params.limit}
    .sort(sortCond)
    .exec (err, templates) ->
      if err
        sails.log.error err
        return resp.badRequest({code: 5000, error: err})

      NotificationTemplate.count cond, (err, total) ->
        if err
          sails.log.error "could not count template list"
          return resp.badRequest({code: 5000, error: err})

        return resp.ok(total: total, result: templates)
      

  add: (req, resp) =>
    params = req.allParams()

    if !params.gameCode
      return resp.badRequest({code: 5067, error: 'missing game code'})
    if !params.category
      return resp.badRequest({code: 5141, error: 'missing category'})
    if !NotificationTemplate.NOTIFY_CATEGORIES[params.category]
      return resp.badRequest({code: 5068, error: 'category is not valid'})
    if !params.title
      return resp.badRequest({code: 5142, error: 'missing title'})
    if !params.content
      return resp.badRequest({code: 5143, error: 'missing content'})
    if !params.isActive?
      return resp.badRequest({code: 5108, error: 'missing param is isActive'})

    Game.findOne code: params.gameCode, (err, game) ->
      if err || !game
        return resp.badRequest({code: 5033, error: 'not found game'})

      NotificationTemplateService.create params, (err, template) ->
        if err
          return resp.badRequest({code: 5000, error: err})
        return resp.ok(success: 'ok')

  update: (req, resp) =>
    params = req.allParams()

    if !params.id
      return resp.badRequest({code: 5144, error: 'missing param id'})

    NotificationTemplateService.update params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(success: 'ok')

  remove: (req, resp) =>
    params = req.allParams()

    if !params.id
      return resp.badRequest({code: 5144, error: 'missing param id'})

    NotificationTemplate.findOne id: params.id, (err, template) ->
      if err
        return resp.badRequest({code: 5000, error: err})
      if !template
        return resp.badRequest({code: 5145, error: 'not found template'})

      NotificationTemplateService.delete params, (err, result) ->
        if err
          return resp.badRequest(err)
        return resp.ok(success: 'ok')

  active: (req, resp) ->
    params = req.allParams()

    if !params.id
      return resp.badRequest({code: 5144, error: 'missing param id'})

    NotificationTemplateService.active params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(success: 'ok')



