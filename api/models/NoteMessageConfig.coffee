_ = require('lodash')

module.exports =
  schema: true
  attributes:
    user:
      model: 'user'
      required: true

    category:
      type: 'string'
      required: true

    isActive:
      type: 'boolean'
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.user
      delete obj.id
      obj
