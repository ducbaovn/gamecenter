_ = require('lodash')
async = require('async')
ObjectId = require('mongodb').ObjectID

exports.listItems = (req, resp)=>
  params = req.allParams()

  # build sort condition
  if !params.sortBy || params.sortBy not in ['code', 'name']
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

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = (params.page - 1) * params.limit

  if params.isActive?
    cond.isActive = params.isActive

  if params.usageType?
    cond.usageType = params.usageType

  if params.filter
    cond.or = [
      code:
        contains: params.filter
    ,
      name:
        contains: params.filter
    ]
  
  if params.extCodes
    try
      params.extCodes = JSON.parse(params.extCodes || '[]')
      if(!_.isArray(params.extCodes))
        return resp.badRequest({code: 5079, error: "extCodes parameter must be array"})  
    catch
      return resp.badRequest({code: 5080, error: "extCodes parameter is invalid"})
    
    cond.code =
      '!': params.extCodes

  # run query
  Item.find cond
  .sort(sortCond)
  .exec (e, items)->
    if e
      sails.log.error "[ItemService.listItems] ERROR: could not get item list ... #{JSON.stringify(e)}"
      return resp.badRequest({code: 5000, error: "could not process"})

    Item.count cond, (e, total)->
      if e
        sails.log.error "[ItemService.listItems] ERROR: could not count item list ... #{JSON.stringify(e)}"
        return resp.badRequest({code: 5000, error: "could not process"})

      resp.status(200).send(total: total, result: items)


exports.createItem = (req, resp)=>
  params = req.allParams()
  params.isInfinitive = Utils.toBoolean(params.isInfinitive)
  params.availableCount = 999999999999 if params.isInfinitive

  # validations
  if !params.itemcode
    return resp.badRequest({code: 5081, error: "missing param itemcode"})
  if !params.name
    return resp.badRequest({code: 5082, error: "missing param name"})
  if !params.isInfinitive && !params.availableCount 
    return resp.badRequest({code: 5083, error: "missing param availableCount or availableCount equal 0"})
  if !params.usageType
    return resp.badRequest({code: 123, error: "missing param usageType"})

  try
    params.partialItems = JSON.parse(params.partialItems || '[]')
  catch
    return resp.badRequest({code: 5084, error: "partialItems parameter is invalid"})

  try
    params.extendInfos = JSON.parse(params.extendInfos || '{}')
  catch
    return resp.badRequest({code: 5085, error: "extendInfos parameter is invalid"})

  if params.isActive == undefined
    params.isActive = true
  if params.startDate && (new Date(params.startDate)).getDate()
    params.startDate = new Date(params.startDate)
  else
    params.startDate = null
  if params.endDate && (new Date(params.endDate)).getDate()
    params.endDate = new Date(params.endDate)
  else
    params.endDate = null

  if params.startDate && params.endDate
    if params.startDate > params.endDate
      return resp.badRequest({code: 5112, error: "startDate is not greater than endDate"})

  # create data
  data =
    gameCode: params.gameCode
    code: params.itemcode
    name: params.name
    icon: params.icon || ''
    iconDetail: params.iconDetail || ''
    description: params.description || ''
    isActive: params.isActive
    startDate: params.startDate
    endDate: params.endDate
    givenCount: parseInt(params.availableCount) || 0
    saleType: params.saleType || Item.SALE_TYPES.ITEM
    usageType: params.usageType
    isReal: params.isReal || false
    extendInfos: params.extendInfos
    isInfinitive: params.isInfinitive

  Item.findOne {code: params.itemcode}, (err1, item)->
    if err1 
      return resp.badRequest({code: 5000, error: err1})

    if item
      return resp.badRequest({code: 5111, error: "item code is existed"})

    Item.create data, (err, item)->
      if err
        sails.log.error "[ItemService.createItem] ERROR: could not create item ... #{JSON.stringify(err)}"
        return resp.badRequest({code: 5088, error: "could not create item"})
      return resp.ok(item)

# The following attribute cannot update:
# - game
# - code
exports.updateItem = (req, resp)=>
  params = req.allParams()
  if !params.itemcode
    return resp.badRequest({code: 5081, error: "missing param itemcode"})
  Item.findOne {code: params.itemcode}, (e, item)->
    if e
      return resp.badRequest({code: 5000, error: "[ItemService.updateItem] ERROR: could not found item ... #{JSON.stringify(e)}"})
    if !item
      return resp.badRequest({code: 5090, error: "[ItemService.updateItem] ERROR: could not found item ..."})

    # validations
    if params.isInfinitive?
      params.isInfinitive = Utils.toBoolean(params.isInfinitive)
    else
      params.isInfinitive = item.isInfinitive
    params.availableCount = 999999999999 if params.isInfinitive
    
    try
      params.extendInfos = JSON.parse(params.extendInfos || '{}')
    catch
      return resp.badRequest({code: 5085, error: "extendInfos parameter is invalid"})

    if params.startDate && (new Date(params.startDate)).getDate()
      params.startDate = new Date(params.startDate)
    else
      params.startDate = null
    if params.endDate && (new Date(params.endDate)).getDate()
      params.endDate = new Date(params.endDate)
    else
      params.endDate = null

    if params.startDate && params.endDate
      if params.startDate > params.endDate
        return resp.badRequest({code: 5112, error: "startDate is not greater than endDate"})

    # edit data
    item.name = params.name                 if params.name
    item.icon = params.icon                 if params.icon
    item.iconDetail = params.iconDetail     if params.iconDetail
    item.description = params.description   if params.description
    item.isActive = params.isActive         if params.isActive?
    item.extendInfos = params.extendInfos
    item.startDate = params.startDate       if params.startDate
    item.endDate = params.endDate           if params.endDate
    item.givenCount = params.availableCount if params.availableCount
    item.isInfinitive = params.isInfinitive
    item.saleType = params.saleType       if params.saleType
    item.isReal = params.isReal             if params.isReal?
    item.usageType = params.usageType if params.usageType

    item.save (e, result)->
      if e
        return resp.badRequest("[ItemService.updateItem] ERROR: could not update item ... #{JSON.stringify(e)}")
      return resp.ok(result)

exports.enableItem = (req, resp)=>
  itemCode = req.param('itemcode')

  Item.findOne {code: itemCode}, (e, item)->
    if e || !item
      sails.log.error "[ItemService.enableItem] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.badRequest({code: 5090, error: "could not found item"})

    item.isActive = true
    item.save()

    resp.status(200).send(success: 'ok')


exports.disableItem = (req, resp)=>
  itemCode = req.param('itemcode')

  Item.findOne {code: itemCode}, (e, item)->
    if e || !item
      sails.log.error "[ItemService.disableItem] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.badRequest({code: 5090, error: "could not found item"})

    item.isActive = false
    item.save()

    resp.status(200).send(success: 'ok')


exports.getItem = (req, resp)=>
  itemCode = req.param('itemcode')

  Item.findOne {code: itemCode}, (e, item)->
    if e || !item
      sails.log.error "[ItemService.getItem] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.badRequest({code: 5090, error: "could not found item"})

    resp.status(200).send(item)

exports.listCombo = (req, resp) =>
  params = req.allParams()

  # build sort condition
  if !params.sortBy || params.sortBy not in ['code', 'name']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = (if params.sortOrder == 'asc' then 1 else -1)

  cond =
    gameCode: params.gameCode

  if params.isActive?
    cond.isActive = params.isActive

  if params.usageType?
    cond.usageType = params.usageType

  # run query
  Item.native (err, cols) ->
    if err
      return resp.badRequest({code: 5000, error: err})

    cols.find cond,
      name: true
      code: true
    .sort(sortCond)
    .toArray (e, results) ->
      if e
        return resp.badRequest({code: 5000, error: e})    
      async.each results, (result, cb) ->
        result.id = result._id
        delete result._id
        cb()
      , (err) ->
        return resp.ok(results)