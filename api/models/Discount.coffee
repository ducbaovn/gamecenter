# Discount.coffee

module.exports =
  schema: true
  attributes:
    exchange:
      model: 'Exchange'
      required: true

    star:
      type: 'integer'
      defaultsTo: 0

    ruby:
      type: 'integer'
      defaultsTo: 0

    # [{item, sl}, ...]
    otherItem:
      type: 'array'
      defaultsTo: []

    startDate:
      type: 'datetime'

    endDate:
      type: 'datetime'

    quantity:
      type: 'integer'

    duringTime: ()->
      offtime = this.endDate.getTime()-this.startDate.getTime()
      seconds = Math.floor(offtime/(1000*60*60*24))
      return seconds

    remainingTime: ()->
      if !this.startDate || !this.endDate
        return -1
      today = new Date()
      if this.startDate > today
        return this.duringDays()
      if this.endDate < today
        return 0

      offtime = this.endDate.getTime()-today.getTime()
      seconds = Math.floor(offtime/(1000))
      return seconds

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj

    toPublic: ()->
      obj = this.toObject()
      obj.remainingTime = this.remainingTime()
      delete obj.exchange
      delete obj.updatedAt
      delete obj.createdAt
      return obj