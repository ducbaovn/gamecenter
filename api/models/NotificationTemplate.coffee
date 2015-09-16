NOTIFY_CATEGORIES = require('./NoteMessage').NOTIFY_CATEGORIES
module.exports = 
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  NOTIFY_CATEGORIES: NOTIFY_CATEGORIES
  attributes:
    gameCode:
      type: 'string'
      required: true

    category:
      type: 'string'
      enum: _.values(NOTIFY_CATEGORIES)
      defaultsTo: NOTIFY_CATEGORIES.SYSTEM
      required: true

    title:
      type: 'string'
      required: true
    
    content:
      type: 'string'
      required: true

    isActive:
      type: 'Boolean'
      required: true
      defaultsTo: false

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj