# it is separated bcz it is more complex

generateGiftCode = (params, cb)->
  user = params.user
  itemid = params.itemid  
  cond =
    user: user.id
    item: itemid
    # isReal: true
    isActive: true
  Bucket.findOne(cond).populate('item').exec (e, bucket)->
    if e
      return cb({code: 5000, error: e}, null)
    if !bucket
      return cb({code: 5045, error: "Not found item on bucket"}, null)

    item = bucket.item
    if !item.isActive
      return cb({code: 5046, error: 'Item was expired'}, null)
    if !item.isReal
      return cb({code: 5047, error: 'Is not real item'}, null)

    if bucket.realItemCode && bucket.realItemCode != ''
      return cb(null, bucket)

    bucket.realItemCode = (new Date()).getTime()
    bucket.save (err)->
      if err
        return cb({code: 5000, error: err}, null)

      return cb(null, bucket)


# user will use this function
exports.showCode = (req, resp)->
  user = req.user
  itemid = req.param('itemid')

  generateGiftCode {user: user, itemid: itemid}, (e, bucket)->
    if e
      return resp.status(400).send(e)

    item = bucket.item
    itemJSON = item.toJSON()
    itemJSON.realItemCode = bucket.realItemCode
    return resp.send(itemJSON)

# nahi staff/admin must use it (ex: admin site)
exports.detectUserGiftCode = (req, resp)->
  cond = 
    realItemCode: req.param('code')

  Bucket.findOne(cond).populate('item').exec (e, bucket)->
    if e || !bucket
      return resp.status(400).send(error: "not found item")

    User.findOne({id: bucket.user}).exec (er, user)->
      if er
        return resp.status(400).send(error: "not found item")

      item = bucket.item
      itemJSON = item.toJSON()
      itemJSON.realItemCode = bucket.realItemCode
      itemJSON.user = user.toJSON()
      quantity = bucket.receivedCount - bucket.usedCount

      itemJSON.quantity = quantity

      return resp.send(itemJSON)

# nahi staff/admin will verify and use it (code will deleted)
exports.verifyGiftCode = (req, resp)->
  realItemCode = req.param('code')
  quantity = parseInt(req.param('quantity') || '1')

  cond = 
    realItemCode: realItemCode

  Bucket.findOne(cond).populate('item').exec (e, bucket)->
    if e || !bucket
      return resp.status(400).send(error: 'not found item')

    if (bucket.receivedCount - bucket.usedCount) < quantity
      return resp.status(400).send(error: 'not enough item')

    bucket.usedCount = bucket.usedCount + quantity
    bucket.realItemCode = ''
    bucket.save (err)->
      if err
        return resp.status(400).send(error: 'could not use item')
      BucketLog.create
        user: bucket.user
        gameCode: bucket.gameCode
        item: bucket.item
        valueChange: quantity
        reason: 'Đổi vật phẩm thật'
      , (err, r)->
        if err
          sails.log.info err
      return resp.send(success: 'ok')

