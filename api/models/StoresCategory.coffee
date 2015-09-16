 # shop.coffee
_ = require('lodash')
 
TYPE =
  INGAME: 'INGAME'
  OUTSIDEGAME: 'OUTSIDEGAME'

module.exports =
  schema: true
  attributes:
    name:
      type: 'string'

    type:
      type: 'string'
      enum: _.values(TYPE)
      defaultsTo: TYPE.INGAME

    imageUrl:
      type: 'string'

    isActive:
      type: 'boolean'
      defaultsTo: true
          
    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj