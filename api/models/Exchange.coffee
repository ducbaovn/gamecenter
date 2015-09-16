# Exchange.coffee
TYPE =
  COMPOUND: 'COMPOUND'
  STORE: 'STORE'

module.exports =
  schema: true
  attributes:
    item:
      model: 'item'
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

    category:
      type: 'array'
      defaultsTo: []

    type:
      enum: _.values(TYPE)
      required: true

    isHot:
      type: 'boolean'
      defaultsTo: false

    isActive:
      type: 'boolean'
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj