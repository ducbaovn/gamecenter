_ = require('lodash')

USER_STATUSES =
  NEW: 'NEW'
  READ: 'READ'
  CLOSE: 'CLOSE'

NOTIFY_CATEGORIES =
  FRIEND: 'FRIEND'
  FAMILY: 'FAMILY'
  EVENT: 'EVENT'
  ACHIEVEMENT: 'ACHIEVEMENT'
  CHALLENGE: 'CHALLENGE'
  SYSTEM: 'SYSTEM'
  RECOMMENDATION: 'RECOMMENDATION'
  SPONSOR: 'SPONSOR'
  CHAT: 'CHAT'


module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  USER_STATUSES: USER_STATUSES
  NOTIFY_CATEGORIES: NOTIFY_CATEGORIES
  # SYS_STATUSES: SYS_STATUSES
  attributes:
    user:
      model: 'user'
      required: true

    gameCode:
      type: 'string'
      required: true

    category:
      type: "string"
      enum: _.values(NOTIFY_CATEGORIES)
      defaultsTo: NOTIFY_CATEGORIES.SYSTEM
      required: true

    imageUrl:
      type: 'string'
      
    title:
      type: 'string'
      required: true

    content:
      type: 'string'
      required: true

    userStatus:
      type: 'string'
      enum: _.values(USER_STATUSES)
      defaultsTo: USER_STATUSES.NEW

    sound:
      type: 'string'

    badge:
      type: 'integer'
      defaultsTo: 1

    expiredAt:
      type: 'datetime'

    extends:
      type: 'json'
      
    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.game
      delete obj.user
      delete obj.badge
      delete obj.sound
      obj
