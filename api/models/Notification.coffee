 # Notification.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
_ = require('lodash')

PLATFORMS =
  ANDROID: 'ANDROID'
  IOS: 'IOS'

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: false

  attributes:
    targets:
      type: 'array'

    note:
      required: true

    timestamp:
      type: 'datetime'
      defaultsTo: new Date()
    
    attempts:
      type: 'integer'
      defaultsTo: 0
    devices:
      type: 'array'
    platform:
      type: 'string'
      required: true
      enum: _.values(PLATFORMS)

    errorCode:
      type: 'string'
    errorType:
      type: 'string'
   