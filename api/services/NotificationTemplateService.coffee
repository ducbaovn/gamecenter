_ = require('lodash')
checkTemplateActive = (data,cb) ->
  if data.isActive
    cond =
      gameCode: data.gameCode
      category: data.category

    NotificationTemplate.find cond, (err, templates) ->
      if err
        sails.log.error err
        cb({code: 5000, error: err})

      _.each templates, (template) ->
        if template.isActive
          dt =
            isActive: false
          NotificationTemplate.update template.id, dt, (err, result) ->
            if err
              return cb({code: 5000, error: err})
            return
      return cb(null)
  else
    return cb(null)

exports.create = (params, done) ->
  data =
    gameCode: params.gameCode
    category: params.category
    title: params.title
    content: params.content
    isActive: params.isActive

  checkTemplateActive data, (err) ->
    if err
      return done(err)

    NotificationTemplate.create data, (err, template) ->
      if err || !template
        return done({code: 5000, error: err},null)
      return done(null, template)

exports.update = (params, done) ->
  params = params
  NotificationTemplate.findOne id: params.id, (err, template) ->
    if err
      return done({code: 5000, error: err})
    if !template
      return done({code: 5145, error: 'not found template'})
    data =
      id: params.id

    data.title = params.title if params.title
    data.content = params.content if params.content

    if params.isActive?
      dt =
        gameCode: template.gameCode
        category: template.category
        isActive: params.isActive

      checkTemplateActive dt, (err) ->
        if err
          return done(err)

        data.isActive = params.isActive
        NotificationTemplate.update data.id, data, (err, result) ->
          if err || !result
            return done({code: 5000, error: err})

          return done(null, result)

    else
      NotificationTemplate.update data.id, data, (err, result) ->
        if err || !result
          return done({code: 5000, error: err})

        return done(null, result)


exports.delete = (params, done) ->
  NotificationTemplate.destroy params.id, (err, result) ->
    if err
      return done({code: 5000, error: err})
    return done(null, result)

exports.active = (params, done) ->
  params = params

  NotificationTemplate.findOne id: params.id, (err, template) ->
    if err
      return resp.badRequest({code: 5000, error: err})
    if !template
      return resp.badRequest({code: 5145, error: 'not found template'})

    dt =
      gameCode: template.gameCode
      category: template.category
      isActive: true

    checkTemplateActive dt, (err) ->
      if err
        return done(err)

      data =
        isActive: true

      NotificationTemplate.update params.id, data, (err, result) ->
        if err || !result
          return done({code: 5000, error: err})

        return done(null, result)

exports.getActiveTemplate = (params, done) ->

  if !params.gameCode || !params.category
    return done(null)

  cond =
    gameCode: params.gameCode
    category: params.category
    isActive: true

  NotificationTemplate.findOne cond, (err, template) ->
    if err || !template
      return done(null)
    
    return done(template)
