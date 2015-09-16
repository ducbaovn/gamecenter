_ = require('lodash')
clone = require('clone')
async = require('async')

randomize = (num)=>
  Math.floor((Math.random() * num) + 1)

findActiveItemIds = (cb)=>
  today = new Date()
  types = [Item.USAGE_TYPES.SINGLE, Item.USAGE_TYPES.PARTIAL]
  cond =
    $or: [
      isActive: true
      startDate: {$lte: today}
      endDate: {$gte : today}
      usageType: {$in: types}
      $where: 'this.givenCount > this.usedCount'
    ,
      isActive: true
      startDate: {$exists: false}
      endDate: {$exists: false}
      usageType: {$in: types}
      $where: 'this.givenCount > this.usedCount'
    ,
      isActive: true
      startDate: {$lte: today}
      endDate: {$exists: false}
      usageType: {$in: types}
      $where: 'this.givenCount > this.usedCount'
    ,
      isActive: true
      startDate: {$exists: false}
      endDate: {$gte : today}
      usageType: {$in: types}
      $where: 'this.givenCount > this.usedCount'
    ]
  Item.native (err, collections)->
    if err
      return cb(err, null)
    collections.find cond
    ,
      _id: true
    .toArray (e, rsts)->
      sails.log.info e
      if e
        return cb(e, null)
      ids = _.pluck(rsts, '_id')
      return cb(null, ids)

findActiveItems = (game, cb)=>
  sails.log.info "findActiveItems......."
  findActiveItemIds (err, ids)->
    if err
      return cb(err, [])
    cond =
      id: ids
    if game?
      cond.gameCode = game.code
    Item.find cond, (er, items)->
      if er
        return cb(er, [])
      return cb(null, items)

countActiveUsers = (cb)=>
  User.count (e, num)->
    if e
      return cb(null, 0)
    cb(null, num)

# 0 <= randV <= 1
randOfferForItem = (item, usersCount)=>
  playPerDay = 20
  today = new Date()
  if usersCount == 0
    return 0
  if item.offerType != Item.OFFER_TYPES.RANDOM
    return 0
  if item.remainingDays() < 0
    return 0
  if item.remainingDays() == 0 && today > item.startDate && today < item.endDate
    return item.givenCount/(usersCount * playPerDay)

  randV = item.givenCount/(usersCount * item.remainingDays() * playPerDay)
  # ensure always lte 1
  if randV > 1
    return 1/randV
  randV

# false = not receive item
# true = receive item
offerItem = (item, usersCount)=>
  randItem = randOfferForItem(item, usersCount)
  if randItem == 0
    return false
  num = Math.round(1/randItem)
  return (randomize(num) == 1)

offerredItems = (game, cb)=>
  done = ()->
    sails.log.info 'done offerredItems......'
  async.parallel
    items: (done)-> findActiveItems(game, done)
    usersCount: (done)-> countActiveUsers(done)
  , (err, results)->
    if err || !results
      return cb(err, [])
    if results.items? && results.items.length == 0
      return cb("no items", [])
    items = results.items
    usersCount = results.usersCount
    givenItems = []
    _.each items, (item)->
      if offerItem(item, usersCount)
        givenItems.push item
    sails.log.info "givenItems: #{givenItems}"
    return cb(null, givenItems)

assignItem = (req, item)->
  sails.log.info 'assignItem........'
  condI =
    user: req.user.id
    item: item.id

  game = req.game
  if game?
    condI.gameCode = game.code


  Bucket.findOne condI, (err, bucket)->
    if err
      sails.log.info err
      return false
    if !bucket?
      data =
        user: req.user.id
        item: item.id
        receivedCount: 1
        isActive: true
        usedCount: 0
        usageType: item.usageType

      if game?
        data.gameCode = game.code
      Bucket.create data, (e, b)->
        sails.log.info e
        sails.log.info b
      return true
    bucket.receivedCount += 1
    bucket.usageType = item.usageType
    bucket.save()
    BucketLog.create
      user: req.user.id
      gameCode: game.code
      item: item.id
      valueChange: 1
      reason: 'Được thưởng vật phẩm'
    , (err, result)->
      if err
        sails.log.info err
    givenCount = item.givenCount
    usedCount = item.usedCount
    if givenCount > 0
      givenCount -= 1
      usedCount += 1
      Item.update {id: item.id}, {givenCount: givenCount, usedCount: usedCount}, (e)->
        sails.log.info e
      item.givenCount = givenCount
      item.usedCount = usedCount
    return true

buildingItem = (item, cb)=>
  buildRelatedItems = (done)->
    relatedItems = item.relatedItems
    if ! relatedItems || relatedItems.length == 0
      return done(null)

    cond =
      code: _.map(relatedItems, 'code')
      isActive: true
    Item.find cond, (e, items)->
      if e || ! items || items.length == 0
        return done(null)

      rtItems = []
      _.each items, (its)->
        meItem = (_.where(relatedItems, {code: its.code})||[])[0]
        quantity = 1
        if meItem?
          quantity = meItem.quantity
        rtItems.push
          id: its.id
          name: its.name
          icon: its.icon
          description: its.description
          quantity: quantity

      item.relatedItems = rtItems
      return done(null)

  buildCompoundItem = (done)->
    compoundItemCode = item.compoundItemCode
    if ! compoundItemCode
      return done(null)

    Item.findOne {code: compoundItemCode}, (e, compoundItem)->
      if e || !compoundItem
        return done(null)

      item.compoundItem =
        id: compoundItem.id
        name: compoundItem.name
        icon: compoundItem.icon
        description: compoundItem.description
        quantity: 1
      return done(null)

  if item.usageType == Item.USAGE_TYPES.SINGLE || item.usageType == Item.USAGE_TYPES.COMPOUND
    return cb(item)

  async.parallel [
    buildRelatedItems,
    buildCompoundItem
  ], (err, result)->
    return cb(null)


exports.receiveItems = (req, resp)=>
  offerredItems req.game, (err, items)->
    if err || !items || items.length == 0
      sails.log.info err
      return resp.status(200).send([])
    cb = (itm)->
      sails.log.info "Finished process item: #{JSON.stringify(itm)}"
    async.forEach items, (item, cb)->
      sails.log.info "item:...."
      sails.log.info item
      assignItem(req, item)
      buildingItem item, ()->
        return cb(null)
    , (e)->
      returnItems = []
      _.each items, (item)->
        itemJSON = item.publicJSON()
        itemJSON.quantity = 1
        returnItems.push itemJSON
      resp.status(200).send(returnItems)


exports.useSingleItem = (req, resp)=>
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
      return resp.status(400).send({code: 5103, error: "not use correctly"})

    updateBucketItem = ()->
      bucket.usedCount += quantity
      Bucket.update {id: bucket.id}, {usedCount: bucket.usedCount}, (e)->
        sails.log.info e
      BucketLog.create
        user: req.user.id
        gameCode: bucket.gameCode
        item: req.itemid
        valueChange: -quantity
        reason: 'Sử dụng vật phẩm'
      , (err, r)->
        if err
          sails.log.info err

    updateUserItem = ()->
      user = req.user
      user.exp += quantity * (item.exp || 0)
      user.energy += quantity * (item.energy || 0)
      user.starMoney += quantity * (item.starMoney || 0)
      user.cleverExp += quantity * (item.cleverExp || 0)
      user.exactExp += quantity * (item.exactExp || 0)
      user.logicExp += quantity * (item.logicExp || 0)
      user.naturalExp += quantity * (item.naturalExp || 0)
      user.socialExp += quantity * (item.socialExp || 0)
      user.langExp += quantity * (item.langExp || 0)
      user.memoryExp += quantity * (item.memoryExp || 0)
      user.observationExp += quantity * (item.observationExp || 0)
      user.judgementExp += quantity * (item.judgementExp || 0)
      User.update {id: user.id},
        exp: user.exp
        energy: user.energy
        cleverExp: user.cleverExp
        exactExp: user.exactExp
        logicExp: user.logicExp
        naturalExp: user.naturalExp
        socialExp: user.socialExp
        langExp: user.langExp
        memoryExp: user.memoryExp
        observationExp: user.observationExp
        judgementExp: user.judgementExp
      , (e)->
        sails.log.info e
      if item.starMoney && item.starMoney > 0
        # TODO
        # pm.project
        pm =
          star: item.starMoney * quantity
          note: "Nhận được điểm thưởng từ item #{item.name}"
          gameCode: req.game.code

        MoneyService.incStars user, pm, (ex, dn)->
          sails.log.info ex

    updateGameItem = ()=>
      game = req.game
      if ! game
        return
      Playing.findOne {user: req.user.id, gameCode: game.code}, (e, playing)->
        if e
          return false
        if ! playing
          playAttr =
            player: req.user.id
            gameCode: game.code
            exp: quantity * item.exp
            money: quantity * item.money
            cleverExp: quantity * item.cleverExp
            exactExp: quantity * item.exactExp
            logicExp: quantity * item.logicExp
            naturalExp: quantity * item.naturalExp
            socialExp: quantity * item.socialExp
            langExp: quantity * item.langExp
            memoryExp: quantity * item.memoryExp
            observationExp: quantity * item.observationExp
            judgementExp: quantity * item.judgementExp
          Playing.create playAttr, (e)->
            sails.log.info e
         
        else
          playing.exp += quantity * (item.exp || 0)        
          playing.cleverExp += quantity * (item.cleverExp || 0)
          playing.exactExp += quantity * (item.exactExp || 0)
          playing.logicExp += quantity * (item.logicExp || 0)
          playing.naturalExp += quantity * (item.naturalExp || 0)
          playing.socialExp += quantity * (item.socialExp || 0)
          playing.langExp += quantity * (item.langExp || 0)
          playing.memoryExp += quantity * (item.memoryExp || 0)
          playing.observationExp += quantity * (item.observationExp || 0)
          playing.judgementExp += quantity * (item.judgementExp || 0)
          playing.save()

        # add money to user's bucket
        BucketService.addItemToBucket 
          gameCode: game.code
          itemid: game.moneyItem
          quantity: item.money
          game: game
          user: req.user
          reason: "Nhận được tiền con khi sử dụng vật phẩm: #{item.name}"
        , (e, bucket)->
          if e
            sails.log.info e

        return true

    useItemLog = ()->
      logData = []
      if item.exp
        logData.push
          user: req.user.id
          gameCode: req.game.code
          category: UserLog.CATEGORY.EXP
          valueChange: quantity * item.exp
          reason: 'USING ITEM'
      if item.energy
        logData.push
          user: req.user.id
          gameCode: req.game.code
          category: UserLog.CATEGORY.ENERGY
          valueChange: quantity * item.energy
          reason: 'USING ITEM'
      if logData[0]
        UserLog.create logData, (e, userLog)->
          if e
            sails.log.info e

    updateBucketItem()
    updateUserItem()
    updateGameItem()
    useItemLog()
    return resp.status(200).send(success: 'ok')

addCombineItem = (req, item)=>
  sails.log.info 'addCombineItem:'
  game = req.game
  compoundItemCode = item.compoundItemCode
  rcond =
    code: compoundItemCode
    isActive: true
    usageType: Item.USAGE_TYPES.COMPOUND
  if game?
    rcond.gameCode = game.code
  Item.findOne rcond, (e, compoundItem)->
    if e
      sails.log.info "......#{JSON.stringify(e)}"
      return false

    sails.log.info compoundItem
    sails.log.info(!compoundItem)
    sails.log.info(!undefined)
    if ! compoundItem || !compoundItem.isValid()
      sails.log.info "......invalid #{JSON.stringify(compoundItem)}"
      return false

    bcond =
      user: req.user.id
      item: compoundItem.id
    if game?
      bcond.gameCode = game.code
    
    BucketLog.create
      user: req.user.id
      gameCode: game.code
      item: compoundItem.id
      valueChange: 1
      reason: 'Nhận vật phẩm ghép'
    , (err, r)->
      if err
        sails.log.info err
    
    Bucket.findOne(bcond).exec (er, bucket)->
      if er
        sails.log.info "......#{JSON.stringify(er)}"
        return false
      if ! bucket
        data =
          user: req.user.id
          item: compoundItem.id
          usageType: compoundItem.usageType
          isActive: true
          receivedCount: 1
          usedCount: 0
        if game?
          data.gameCode = game.code
        Bucket.create(data).exec (ex,x)->
          if ex
            sails.log.info ex
            return false
          return true
      bucket.receivedCount += 1
      Bucket.update {id: bucket.id}, {receivedCount: bucket.receivedCount}, (e)->
        if e
          sails.log.info e
          return false
        return true

exports.combineItems = (req, resp)=>
  cond =
    user: req.user.id
    item: req.itemid
    usageType: Item.USAGE_TYPES.PARTIAL

  Bucket.findOne(cond).populate('item').exec (e, bucket)->
    if e
      return resp.status(400).send({code: 5000, error: e})

    if ! bucket || bucket.receivedCount <= bucket.usedCount
      return resp.status(400).send({code: 5048, error: "not enough items"})

    item = bucket.item
    if ! item || ! item.isActive || item.remainingDays() <= 0
      return resp.status(400).send({code: 5049, error: 'invalid part-item'})

    relatedItems = item.relatedItems
    if ! relatedItems || relatedItems.length == 0
      return resp.status(400).send({code: 5050, error: "not found related items"})

    codes = _.pluck(relatedItems, 'code')
    hashCodes = _.zipObject(_.pluck(relatedItems,'code'), _.pluck(relatedItems,'quantity'))

    Item.find {code: codes, isActive: true}, (er, items)->
      if er
        return resp.status(400).send({code: 5000, error: er})

      if items.length == 0
        return resp.status(400).send({code: 5045, error: "not valid related items"})

      itemIds = _.pluck(items, 'id')
      Bucket.find({user: req.user.id, item: itemIds}).populate('item').exec (e, buckets)->
        if e
          return resp.status(400).send({code: 5000, error: e})

        if buckets.length < itemIds.length
          return resp.status(400).send({code: 5051, error: "not enough related items"})

        ensureValidBuckets = (bkts)->
          rt = true
          _.each bkts, (bkt)->
            bkItem = bkt.item
            if !bkItem?
              rt = false
            qty = hashCodes[bkItem.code] || 1
            if ! bkItem.isActive || bkt.receivedCount < 1 || bkt.receivedCount < (bkt.usedCount + qty)
              rt = false
          return rt
        if ! ensureValidBuckets(buckets)
          return resp.status(400).send({code: 5052, error: "not enough related items quantity"})


        async.forEach buckets, (bk, cb)->
          bkItem = bk.item
          if ! bkItem
            return cb(null)
          qty = hashCodes[bkItem.code] || 1
          bk.usedCount = bk.usedCount + qty
          bk.save()

          BucketLog.create
            user: req.user.id
            gameCode: req.game.code
            item: bkItem
            valueChange: -qty
            reason: 'Ghép vật phẩm'
          , (err, result)->
            if err
              sails.log.info(err)
          
          return cb(null)
        , (e)->
          if e
            return resp.status(400).send({code: 5053, error: "not valid item"})

          addCombineItem(req, item)
          return resp.status(200).send(success: 'ok')


exports.myItems = (req, resp)=>
  cond =
    user: req.user.id
    isActive: true
    usageType: [Item.USAGE_TYPES.PARTIAL,Item.USAGE_TYPES.COMPOUND]
  game = req.game
  if game?
    cond.gameCode = game.code
  Bucket.find(cond).populate('item').exec (err, buckets)->
    if err
      sails.log.info err
      return resp.status(400).send({code: 5000, error: err})

    async.forEach buckets, (bucket, cb)->
      if !bucket.item
        return cb(null)
      buildingItem bucket.item, ()->
        return cb(null)
    , (e)->
      items = []
      _.each buckets, (bucket)->
        quantity = bucket.receivedCount - bucket.usedCount
        item = bucket.item.publicJSON()
        item.quantity = quantity
        if item.quantity > 0
          items.push item
      resp.status(200).send(items)



exports.addItemUserGame = (item, user, gameCode = Game.VISIBLE_APIS.MATH)=>

  Game.findOne {code: gameCode}, (e, game)->
    if e || !game
      return false
    
    cond =
      item: item.id
      user: user.id
    
    Bucket.findOne cond, (e, bk)->
      if e
        return false
      if bk
        bk.receivedCount += 1
        bk.save()
        BucketLog.create
          user: user.id
          gameCode: bk.gameCode
          item: item.id
          valueChange: 1
          reason: 'Thắng phòng NAHI'
        , (err, r)->
          if err
            sails.log.info err
        return true

      data =
        item: item.id
        user: user.id
        gameCode: game.code
        receivedCount: 1
        usedCount: 0
      Bucket.create data, (e, bucket)->
        sails.log.info "addItemUserGame success"
      BucketLog.create
        user: user.id
        gameCode: game.code
        item: item.id
        valueChange: 1
        reason: 'Thắng phòng NAHI'
      , (err, r)->
        if err
          sails.log.info err
      return true