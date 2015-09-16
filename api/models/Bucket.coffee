 # Bucket.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
_ = require('lodash')

USAGE_TYPES = require('./Item').USAGE_TYPES

module.exports =

  attributes:
    user:
      model: 'user'
      required: true
      
    gameCode:
      type: 'string'

    item:
      model: 'item'
      required: true

    # the num what user received items
    receivedCount:
      type: 'integer'
      required: true
    
    usageType:
      type: 'string'
      required: true
      enum: _.values(USAGE_TYPES)

    # how many times user used the item
    usedCount:
      type: 'integer'
      defaultsTo: 0

    # auto generated when item is used
    realItemCode:
      type: 'string'
      defaultsTo: null

    isActive:
      type: 'boolean'
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      
      delete obj.realItemCode
      obj