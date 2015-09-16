
 # Item.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

_ = require('lodash')
# how to use the item
# OPEN: mo vat pham
# INCREASE: su dung tang/giam thuoc tinh
# COMPOUND: manh de ghep thanh vat pham khac
USAGE_TYPES =
  OPEN: 'OPEN'
  INCREASE: 'INCREASE'
  COMPOUND: 'COMPOUND'

# how to return after buy
# BUCKET: tra vat pham ve tui do
# CARD: tra ma the cao 
SALE_TYPES =
  ITEM: 'ITEM'
  CARD: 'CARD'


module.exports =
  USAGE_TYPES: USAGE_TYPES
  SALE_TYPES: SALE_TYPES

  attributes:
    gameCode:
      type: 'string'

    name:
      type: 'string'
      required: true

    code:
      type: 'string'
      required: true
      unique: true

    icon:
      type: 'string'

    iconDetail:
      type: 'string'

    description:
      type: 'string'


    # exp:
    #   type: 'integer'
    #   defaultsTo: 0

    # energy:
    #   type: 'integer'
    #   defaultsTo: 0

    # # tien sao
    # starMoney:
    #   type: 'integer'
    #   defaultsTo: 0

    # cleverExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # exactExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # logicExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # naturalExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # socialExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # langExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # memoryExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # observationExp:
    #   type: 'integer'
    #   defaultsTo: 0

    # judgementExp:
    #   type: 'integer'
    #   defaultsTo: 0

    isActive:
      type: 'boolean'
      defaultsTo: true

    startDate:
      type: 'datetime'
    endDate:
      type: 'datetime'

    saleType:
      type: 'string'
      required: true
      enum: _.values(SALE_TYPES)
      defaultsTo: SALE_TYPES.ITEM

    usageType:
      type: 'string'
      required: true
      enum: _.values(USAGE_TYPES)

    # partial item list
    # save both in PARTIAL item and COMPOUND item
    # [{code: 'code', quantity: x}]
    # relatedItems:
    #   type: 'array'

    # compoundItemCode:
    #   type: 'string'
    #   defaultsTo: null

    isReal:
      type: 'boolean'
      defaultsTo: false

    # number of available quantity
    givenCount:
      type: 'integer'
      defaultsTo: 0

    usedCount:
      type: 'integer'
      defaultsTo: 0

    luckyTimes:
      type: 'integer'
      defaultsTo: 0

    extendInfos:
      type: 'json'
      defaultsTo: {}    

    # infinitive available count, will reset to 999.999.999.999 every day
    isInfinitive:
      type: 'boolean'
      defaultsTo: false

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

    duringDays: ()->
      if !this.startDate? || !this.endDate?
        return 30
      offtime = this.endDate.getTime()-this.startDate.getTime()
      days = Math.floor(offtime/(1000*60*60*24))
      return days

    remainingDays: ()->
      if !this.startDate? || !this.endDate?
        return 30
      today = new Date()
      if this.startDate > today
        return this.duringDays()
      if this.endDate < today
        return 0

      offtime = this.endDate.getTime()-today.getTime()
      days = Math.floor(offtime/(1000*60*60*24))
      return days

    isValid: ()->
      obj = this.toObject()
      return obj.isActive

    toJSON: ()->
      obj = this.toObject()
      obj.availableCount = obj.givenCount || obj.availableCount
      obj.partialItems = _.clone(obj.relatedItems || obj.partialItems)
      obj.remainingTime = this.remainingTime()

      delete obj.relatedItems
      delete obj.givenCount
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.compoundItemCode
      delete obj.usedCount
      delete obj.luckyTimes
      obj

    publicJSON: ()->
      return {
        id: this.id
        name: this.name
        icon: this.icon
        iconDetail: this.iconDetail
        description: this.description
        code: this.code
        usageType: this.usageType
        isReal: this.isReal
      }