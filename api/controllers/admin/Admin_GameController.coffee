# Admingamecontroller
# @description :: Server-side logic for managing games

_ = require('lodash')

module.exports =
  list: (req, resp) ->
    params = req.allParams()

    # build sort condition
    if !params.sortBy || params.sortBy not in ['code', 'name', 'ordering', 'createdAt']
      params.sortBy = 'createdAt'
    if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
      params.sortOrder = 'desc'
    sortCond = {}
    sortCond[params.sortBy] = params.sortOrder

    # build condition   
    params.page = parseInt(params.page) || 1
    params.limit = parseInt(params.limit) || 10

    cond = {}

    if params.limit > 0
      cond.limit = params.limit
      cond.skip = (params.page - 1) * params.limit

    if params.filter
      cond.or = [
        code:
          contains: params.filter
      ,
        name:
          contains: params.filter
      ]

    if params.isActive?
      cond.isActive = params.isActive

    Game.find cond
    .sort(sortCond)
    .populate('moneyItem')
    .exec (e, games) ->
      if e
        sails.log.error e
        return resp.badRequest({code: 5000, error: e})

      Game.count cond, (e, total) ->
        if e
          sails.log.error "could not count game list"
          return resp.badRequest({code: 5000, error: e})

        return resp.ok(total: total, result: games)

  listCombo: (req, resp) ->
    params = {}
    params.sortBy = 'name'  
    params.limit = -1

    GameService.list params, (err, list)->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)
      return resp.ok(list)

  brainList: (req, resp)->
    params = {}
    params.sortBy = 'name'  
    params.parent = Game.VISIBLE_APIS.BRAIN
    params.limit = -1

    GameService.list params, (err, list)->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)
      return resp.ok(list)

  add: (req, resp) ->
    params = req.allParams()

    if !params.code || params.code.trim().length == 0
      return resp.badRequest({code: 5067, error: 'missing param game code or not valid'})
    if !params.name || params.name.trim().length == 0
      return resp.badRequest({code: 5130, error: 'missing param game name'})
    if !params.icon
      return resp.badRequest({code: 5131, error: 'missing param icon'})
    if !params.packageUrl
      return resp.badRequest({code: 5132, error: 'missing param package url'})
    if !params.packageId
      return resp.badRequest({code: 5133, error: 'missing param package id'})

    GameService.create params, (err, game) =>
      if err
        return resp.badRequest(err)

      return resp.ok(success: 'ok')

  update: (req, resp) ->    
    params = req.allParams()

    if !params.id
      return resp.badRequest({code: 5067, error: 'missing param game id'})
  
    GameService.update params, (err, result) ->
      if err
        return resp.badRequest(err)

      return resp.ok(success: 'ok')

  remove: (req, resp) ->
    params = req.allParams()
    if !params.id
      return resp.badRequest({code: 5067, error: 'missing param game id'})

    GameService.delete params, (err, result) =>
      if err
        return resp.badRequest(err)

      return resp.ok(success: 'ok')

  status: (req, resp) ->
    params = req.allParams()
    if !params.id
      return resp.badRequest({code: 5067, error: 'missing param game id'})
    if !params.isActive?
      return resp.badRequest({code: 5108, error: 'missing param isActive'})

    GameService.active params, (err, result) ->
      if err
        return resp.badRequest(err)

      return resp.ok(success: 'ok')

