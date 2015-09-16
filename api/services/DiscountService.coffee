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

checkDate = (params, done) ->
  cond = {}
  if params.id
    cond.id =
      '!': params.id
  if params.exchange
    cond =
      exchange: params.exchange
  if params.startDate || params.endDate
    if !params.startDate || !params.endDate
      return done('Must have both param startDate and endDate')
    if !(new Date(params.startDate)).getDate() || !(new Date(params.endDate)).getDate()
      return done({code: 6112, error: 'Param startDate or endDate is not datetime type', log: "[SalesPriceService.add] ERROR: Param startDate or endDate is not datetime type"})
    if params.startDate > params.endDate
      return done({code: 6113, error: 'Params endDate must be greater than startDate', log: "[SalesPriceService.add] ERROR: Params endDate must be greater than startDate"})
    cond.startDate =
      '<=': params.endDate
    cond.endDate =
      '>=': params.startDate

  Discount.find cond, (err, dsc) ->
    if err
      return done({code: 5000, error: "could not process", log: "[DiscountService.list] ERROR: could not get list ... #{JSON.stringify(err)}"})
    if dsc
      return done(null, dsc)
    return done()

exports.list = (params, done) ->
  if params.date
    params.startDate = params.endDate = params.date

  checkDate params, (err, dsc) ->
    if err
      return done(err)
    if dsc
      return done(null, dsc)

exports.listDiscountAtTime = (params, done) ->
  date = new Date()
  date = date.toDateString()
  params.startDate = params.endDate = date

  checkDate params, (err, dsc) ->
    if err
      return done(err)
    if dsc.length != 0
      dsc[0] = dsc[0].toPublic()
      return done(null, dsc[0])
    else
      return done()

exports.add = (params, done) ->
  if !params.exchange
    return done({code: 6110, error: 'Missing param exchange', log: "[DiscountService.add] ERROR: Missing param exchange"})
  if !params.startDate || !params.endDate
    return done({code: 6111, error: 'Missing param startDate or endDate', log: "[DiscountService.add] ERROR: Missing param startDate or endDate"})
  Exchange.findOne params.exchange, (err, ex) ->
    if err || !ex
      return done({code: 6109, error: 'could not found Exchange', log: "[DiscountService.add] ERROR: Could not found Exchange"})

    data =
      exchange: params.exchange

    checkOtherItem params, (err, result1) ->
      if err
        return done({code: 6108, error: '[DiscountService.add] ERROR: could not found otherItem'})
      if result1
        data.otherItem = params.otherItem

      data.star = params.star || 0
      data.ruby = params.ruby || 0
      data.startDate = params.startDate
      data.endDate = params.endDate
      data.quantity = params.quantity if params.quantity

      Exchange.findOne id: params.exchange, (err, exchange) ->
        if err || !exchange
          return done({code: 6109, error: "[DiscountService.add] ERROR: could not found exchange", log: "[DiscountService.add] ERROR: could not found exchange"})
        checkDate params, (err1, result) ->
          if err1
            return done(err1)
          if result.length != 0
            return done({code: 6114, error: "[DiscountService.add] ERROR: Discount is existed", log: "[DiscountService.add] ERROR: Discount is existed"})

          Discount.create data, (err1, newItem) ->
            if err1
              sails.log.error "[ExchangeService.addItems] ERROR: could not add item into exchanges ... #{JSON.stringify(err1)}"
              return done({code: 5000, error: err1, log: "[ExchangeService.addItems] ERROR: could not add item into exchanges ... #{JSON.stringify(err1)}"})
            return done(null, newItem)

exports.update = (params, done) ->
  if !params.id
    return done({code: 6106, error: "Missing param id", log: "[DiscountService.udpate] ERROR: Missing param id}"})

  Discount.findOne id: params.id, (err, discount) ->
    if err
      return done({code: 5000, error: err, log: "[DiscountService.udpate] ERROR: #{JSON.stringify(err)}"})
    if !discount
      return done({code: 6115, error: "Could not found Discount", log: "[ExchangeService.udpate] ERROR: Could not found Discount}"})
    
    checkDate params, (err1, result) ->
      if err1
        return done(err1)
      if result.length != 0
        return done({code: 6114, error: "[DiscountService.update] ERROR: Discount is existed", log: "[DiscountService.update] ERROR: Discount is existed"})

      discount.star = params.star if params.star
      discount.ruby = params.ruby if params.ruby
      discount.quantity = params.quantity if params.quantity
      discount.startDate = params.startDate if params.startDate
      discount.endDate = params.endDate if params.endDate

      checkOtherItem params, (err, result1) ->
        if err
          return done({code: 6108, error: '[DiscountService.add] ERROR: could not found otherItem'})
        if result1
          discount.otherItem = params.otherItem

        discount.save (err, discount) ->
          if err
            return done({code: 5000, error: err, log: "[ExchangeService.udpate] ERROR: #{JSON.stringify(err)}"})
          return done(null, discount)

exports.remove = (params, done) ->
  if !params.id
    return done({code: 6106, error: 'Missing param id'})
  Discount.destroy id: params.id, (err, del) ->
    if err
      return done({code: 5000, error: err, log: "[DiscountService.remove] ERROR: #{JSON.stringify(err)}"})
    if del.length == 0
      return done({code: 6115, error: 'Could not found discount', log: "[DiscountService.remove] ERROR: Could not found discount..."})
    return done(null,del)