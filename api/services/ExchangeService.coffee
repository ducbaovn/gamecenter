ObjectID = require('mongodb').ObjectID
checkOtherItem = (params, done) ->
  if params.otherItem
    async.each params.otherItem, (other, cb) ->
      Item.findOne other.item, (err, item) ->
        if err || !item
          return cb('could not found otherItem')
        return cb()
    , (err) ->
      if err
        return done(err)
      return done(null, true)
  else
    return done(null, false)

checkCategory = (params, done) ->
  if params.category
    async.each params.category, (categoryid, cb) ->
      StoresCategory.findOne categoryid, (err, ct) ->
        if err
          return cb({code: 5000, error: err})
        if !ct
          return cb({code: 6102, error: '[ExchangeService.addItems] ERROR: could not found category'})
        return cb(null, ct)
    , (err) ->
      if err
        return done(err)
      return done(null, true)
  else
    return done(null, false)

checkGame = (params, done) ->
  if params.gameCode
    Item.find gameCode: params.gameCode, (err, items) ->
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

checkItem = (params, done) ->
  if params.name
    Item.findOne {name: params.name}, (err, it) ->
      if it
        return done(it.id)
      return done(false)
  else if params.code
    Item.findOne {code: params.code}, (err, it) ->
      if it
        return done(it.id)
      return done(false)
  else return done(true)

exports.listItems = (params, done) ->
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10

  cond = {}

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = (params.page - 1) * params.limit

  if params.category?
    cond.category = params.category
  if params.type
    cond.type = params.type
  if params.isHot
    cond.isHot = params.isHot
  if params.isActive?
    cond.isActive = params.isActive

  checkGame params, (itemids) ->
    if itemids != true
      cond.item = itemids

    checkItem params, (itemid) ->
      if itemid != true
        cond.item = itemid
      Exchange.find cond
      .populate('item')
      .exec (err, exchange)->
        if err
          sails.log.error "[ExchangeService.listItems] ERROR: could not get item list ... #{JSON.stringify(err)}"
          return done({code: 5000, error: "could not process"})
        async.each exchange, (exchange, cb) ->
          params =
            exchange: exchange.id
          DiscountService.listDiscountAtTime params, (err, discount) ->
            if discount
              exchange.discount = discount
            cb()
        , (err) ->
          Exchange.count cond, (err1, total)->
            if err1
              sails.log.error "[ExchangeService.listItems] ERROR: could not count item list ... #{JSON.stringify(err1)}"
              return done({code: 5000, error: err1})
            
            return done(total: total, result: exchange)

exports.listItemStore = (params, done) ->
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10

  cond =
    type: 'STORE'


  if params.limit > 0
    cond.limit = params.limit
    cond.skip = (params.page - 1) * params.limit

  if params.category?
    cond.category = params.category
  if params.isHot
    cond.isHot = params.isHot
  if params.isActive?
    cond.isActive = params.isActive

  checkGame params, (itemids) ->
    if itemids != true
      cond.item = itemids

    checkItem params, (itemid) ->
      if itemid != true
        cond.item = itemid
      Exchange.find cond
      .populate('item')
      .exec (err, exchange)->
        if err
          sails.log.error "[ExchangeService.listItems] ERROR: could not get item list ... #{JSON.stringify(err)}"
          return done({code: 5000, error: "could not process"})
        async.each exchange, (exchange, cb) ->
          params =
            exchange: exchange.id
          DiscountService.listDiscountAtTime params, (err, discount) ->
            if discount
              exchange.discount = discount
            cb()
        , (err) ->
          Exchange.count cond, (err1, total)->
            if err1
              sails.log.error "[ExchangeService.listItems] ERROR: could not count item list ... #{JSON.stringify(err1)}"
              return done({code: 5000, error: err1})
            
            return done(total: total, result: exchange)


exports.addItems = (params, done) ->
  if !params.item
    return done({code: 6100, error: 'Missing param item'})
  if !params.type
    return done({code: 6107, error: 'Missing param type'})
  Item.findOne params.item, (err, it) ->
    if err || !it
      return done({code: 6101, error: 'could not found item'})

    data =
      item: params.item

    checkCategory params, (err, result) ->
      if err
        return done(err)
      checkOtherItem params, (err, result1) ->
        if err
          return done({code: 6108, error: '[ExchangeService.addItems] ERROR: could not found otherItem'})
        data.otherItem = if result1 then params.otherItem else []

        data.category = params.category
        data.star = params.star || 0
        data.ruby = params.ruby || 0
        data.type = params.type
        data.isHot = params.isHot
        data.isActive = params.isActive if params.isActive?

        cond =
          type: data.type
          item: ObjectID(data.item)
          star: data.star
          ruby: data.ruby
        
        if data.otherItem.length == 0
          cond.otherItem = []
        else 
          cond.otherItem = { $in: data.otherItem}

        Exchange.native (err, cols) ->
          if err
            return done({code: 5000, error: err})
          cols.find cond
          .toArray (e, exchanges) ->
            if e
              return done({code: 5000, error: e})
            if exchanges.length > 0
              return done({code: 6103, error: 'Item in exchanges is existed'})
            Exchange.create data, (err1, newItem) ->
              if err1
                sails.log.error "[ExchangeService.addItems] ERROR: could not add item into exchanges ... #{JSON.stringify(err1)}"
                return done({code: 5000, error: err1})
              return done(null, newItem)

exports.updateItems = (params, done) ->
  if !params.id
    return done({code: 6106, error: "Missing param id", log: "[ExchangeService.udpateItems] ERROR: Missing param id}"})

  Exchange.findOne id: params.id, (err, item) ->
    if err
      return done({code: 5000, error: err, log: "[ExchangeService.udpateItems] ERROR: #{JSON.stringify(err)}"})
    if !item
      return done({code: 6109, error: "Could not found item in Exchange", log: "[ExchangeService.udpateItems] ERROR: Could not found item in Exchange}"})
    checkCategory params, (err, result) ->
      if err
        return done(err)
      if result
        item.category = params.category

      checkOtherItem params, (err, result1) ->
        if err
          return done({code: 6108, error: '[ExchangeService.updateItems] ERROR: could not found otherItem'})
        if result1
          item.otherItem = params.otherItem

        item.star = params.star if params.star
        item.ruby = params.ruby if params.ruby
        item.type = params.type if params.type
        item.isHot = params.isHot if params.isHot
        item.isActive = params.isActive if params.isActive?

        item.save (err, item) ->
          if err
            return done({code: 5000, error: err, log: "[ExchangeService.udpateItems] ERROR: #{JSON.stringify(err)}"})
          return done(null, item)

exports.removeItems = (params, done) ->
  if !params.id
    return done({code: 6106, error: 'Missing param id'})
  Exchange.destroy id: params.id, (err, del) ->
    if err
      return done({code: 5000, error: err, log: "[ExchangeService.remove] ERROR: #{JSON.stringify(err)}"})
    if del.length == 0
      return done({code: 6109, error: 'Could not find exchange', log: "[ExchangeService.removeItems] ERROR: Could not remove..."})
    return done(null,del)