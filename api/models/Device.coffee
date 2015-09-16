_ = require('lodash')
PLATFORMS =
  ANDROID: 'ANDROID'
  IOS: 'IOS'

module.exports =
  schema: true
  PLATFORMS: PLATFORMS
  autoCreatedAt: true
  attributes:
    user:
      model: 'user'
      required: true

    platform:
      type: 'string'
      required: true
      enum: _.values(PLATFORMS)

    deviceid:
      type: 'string'
      required: true

    enabled:
      type: 'boolean'
      defaultsTo: true
    