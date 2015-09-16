_ = require('lodash')
async = require('async')

checkUsageType = (params, done) ->
  if params.category
    if params.category == 'COMPOUND'
      cond =
        usageType: 'COMPOUND'
    else
      cond =
        usageType:
          '!': 'COMPOUND'
    Item.find cond, (err, items) ->
      if items.length > 0
        it = []
        async.each items, (item, cb) ->
          it.push(item.id)
          cb()
        , (err) ->
          return done(it)
      else
        return done(false)
  else
    return done(true)

exports.getMyBucket = (params, done) ->
  if !params.user
    return done({code: 123, error: '[BucketService.getMyBucket] Missing param user'})
  User.findOne params.user, (err1, user) ->
    if err1 || !user
      return done({code: 123, error: '[BucketService.getMyBucket] Could not find user'})
    cond =
      user: params.user
    params.page = parseInt(params.page) || 1
    params.limit = parseInt(params.limit) || 10
    if params.limit > 0
      cond.limit = params.limit
      cond.skip = (params.page - 1) * params.limit
    if params.gameCode
      cond.gameCode = params.gameCode
    checkUsageType params, (itemids) ->
      if itemids != true
        cond.item = itemids
      Bucket.find cond
      .populate("item")
      .exec (err, buckets) ->
        if err
          return done({code: 5000, error: '[BucketService.getMyBucket] ERROR: could not found bucket'})

        Bucket.count cond, (err1, total)->
          if err1
            sails.log.error "[BucketService.listItems] ERROR: could not count item list ... #{JSON.stringify(err1)}"
            return done({code: 5000, error: err1})
          return done(total: total, result: buckets)

exports.addItemToBucket = (params, done)=>  
  quantity = parseInt(params.quantity) || 0
  params.reason = params.reason || 'Nhận được vật phẩm'

  if quantity <= 0
    return done({code: 5095, error: "quantity is invalid"})

  if params.itemid
    cond = {id: params.itemid}    
  else
    cond = {code: params.itemcode}

  Item.findOne cond, (err1, item)->
    if err1
      sails.log.error "[BucketService.addItemToBucket] ERROR: could not found item ... #{JSON.stringify(err1)}"
      return done({code: 5000, error: err1})
    if !item
      sails.log.error "[BucketService.addItemToBucket] ERROR: could not found item"
      return done({code: 5090, error: "could not found item"})

    if item.givenCount <= 0 || item.givenCount - quantity < 0
      sails.log.error "[BucketService.addItemToBucket] ERROR: out of quantity"
      return done({code: 5096, error: "[BucketService.addItemToBucket] ERROR: out of quantity"})

    User.findOne params.userid, (err1, user) ->
      if err1 || !user
        return done({code: 5000, error: '[BucketService.addItemToBucket] ERROR: could not found user'})

      Game.findOne code: params.gameCode, (err2, game) ->
        if err2 || !game
          return done({code: 5000, error: '[BucketService.addItemToBucket] ERROR: could not found game'})

        cond =
          gameCode: params.gameCode
          user: params.userid
          item: item.id
        Bucket.findOne cond, (err3, bucket)->
          if err3
            sails.log.error "[BucketService.addItemToBucket] ERROR: could not found item on bucket ... #{JSON.stringify(err3)}"
            return done({code: 5000, error: "[BucketService.addItemToBucket] ERROR: could not found item on bucket ... #{JSON.stringify(err3)}"})

          if bucket?
            if !bucket.isActive
              sails.log.error "[BucketService.addItemToBucket] ERROR: bucket item is disabled"
              return done({code: 5097, error: "[BucketService.addItemToBucket] ERROR: bucket item is disabled"})

            item.givenCount -= quantity
            if item.givenCount <= 0
              item.givenCount = 0
            item.save (err4, item)->
              if err4
                return done({code: 5000, error: "[BucketService.addItemToBucket] ERROR: could not save item ... #{JSON.stringify(err4)}"})

              bucket.receivedCount += quantity
              bucket.save()
              BucketLog.create
                user: params.userid
                gameCode: params.gameCode
                item: item.id
                valueChange: quantity
                reason: params.reason
              , (e, log)->
                if e
                  sails.log.error "[BucketService.BucketLog] ERROR: can not log add item to user ... #{JSON.stringify(e)}"
                  return done({code: 5000, error: "can not log add item to bucket"})
              return done(null, bucket)

          else
            data =
              gameCode: params.gameCode
              user: params.userid
              item: item.id
              receivedCount: quantity
              usedCount: 0
              isActive: true
              usageType: item.usageType

            Bucket.create data, (e, bucket)->
              if e
                sails.log.error "[BucketService.addItemToBucket] ERROR: can not add item to user ... #{JSON.stringify(e)}"
                return done({code: 5098, error: "can not add item to bucket"})
              item.givenCount -= quantity
              item.save (err5, item)->
                if err5
                  return done({code: 5000, error: "[BucketService.addItemToBucket] ERROR: could not save item ... #{JSON.stringify(err5)}"})

                BucketLog.create
                  user: params.userid
                  gameCode: params.gameCode
                  item: item.id
                  valueChange: quantity
                  reason: params.reason
                , (e, log)->
                  if e
                    sails.log.error "[BucketService.BucketLog] ERROR: can not log add item to user ... #{JSON.stringify(e)}"
                    return done({code: 5000, error: "can not log add item to bucket"})
                return done(null, bucket)


# exports.getMyBucket = (req, resp)=>
#   return MathItemService.myItems(req, resp)


useSingleItem = (req, resp)=>
  quantity = parseInt(req.param('quantity')) || 1  
  cond =
    user: req.user.id
    item: req.itemid
    usageType: [Item.USAGE_TYPES.SINGLE, Item.USAGE_TYPES.COMPOUND]

  Bucket.findOne(cond).populate('item').exec (e, bucket)->
    if e
      return resp.status(400).send({code: 5000, error: e})
    if ! bucket
      return resp.status(400).send({code: 5094, error: 'not found item'})

    item = bucket.item
    if ! item || ! item.isActive || item.remainingDays() <= 0
      return resp.status(400).send({code: 5094, error: 'not found item'})

    if bucket.receivedCount < bucket.usedCount + quantity
      return resp.status(400).send({code: 5096, error: 'out of quantity'})

    if item.isReal
      return resp.status(400).send({code: 5100, error: "api don't support using real item at this time"})

    updateBucketItem = ()->
      bucket.usedCount += quantity
      Bucket.update {id: bucket.id}, {usedCount: bucket.usedCount}, (e)->
        sails.log.info e

    updateBucketItem()
    BucketLog.create
      user: req.user.id
      gameCode: bucket.gameCode
      item: req.itemid
      valueChange: -quantity
      reason: 'Sử dụng vật phẩm'
    , (err, r)->
      if err
        sails.log.info err
    return resp.status(200).send(success: 'ok')


exports.useItemOnBucket = (req, resp)=>
  quantity = parseInt(req.param('quantity')) || 0
  if quantity <= 0
    return resp.status(400).send({code: 5099, error: "quantity must greater than 0"})

  itemCode = req.param('itemcode')

  Item.findOne {code: itemCode}, (e, item)->
    if e
      sails.log.error "[BucketService.useItemOnBucket] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.status(400).send({code: 5000, error: e})
    if !item
      sails.log.error "[BucketService.useItemOnBucket] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.status(400).send({code: 5090, error: "could not found item"})
    
    req.itemid = item.id
    if item.usageType == Item.USAGE_TYPES.PARTIAL
      resp.status(400).send({code: 5100, error: "api don't support using partial item at this time"})
    else if item.usageType in [Item.USAGE_TYPES.SINGLE, Item.USAGE_TYPES.COMPOUND]
      useSingleItem(req, resp)
    else
      resp.status(400).send({code: 5102, error: "could not use item"})


exports.getBucketItem = (req, resp)=>
  itemCode = req.param('itemcode')

  Item.findOne {code: itemCode}, (e, item)->
    if e
      sails.log.error "[BucketService.getBucketItem] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.status(400).send({code: 5000, error: e})
    if !item
      sails.log.error "[BucketService.getBucketItem] ERROR: could not found item ... #{JSON.stringify(e)}"
      return resp.status(400).send({code: 5090, error: "could not found item"})

    cond =
      gameCode: req.param('gameCode')
      user: req.user.id
      item: item.id
      isActive: true

    Bucket.findOne(cond).populate('item').exec (e, bucket)->
      if e
        sails.log.error "[BucketService.getBucketItem] ERROR: could not found bucket item ... #{JSON.stringify(e)}"
        return resp.status(400).send({code: 5000, error: e})
      if !bucket
        sails.log.error "[BucketService.getBucketItem] ERROR: could not found bucket item ... #{JSON.stringify(e)}"
        return resp.status(400).send({code: 5094, error: "could not found bucket item"})

      item = bucket.item.publicJSON()
      item.quantity = bucket.receivedCount - bucket.usedCount

      resp.status(200).send(item)
