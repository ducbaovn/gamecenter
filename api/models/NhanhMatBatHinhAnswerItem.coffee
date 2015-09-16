_ = require('lodash')

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true

  attributes:
    category:
      model: 'ImageCategory'
      required: true

    zIndex:
      type: 'integer'
      required: true

    factor:
      type: 'float'
      defaultsTo: 1

    answer:
      model: 'NhanhMatBatHinhAnswer'
      required: true

    isActive:
      type: 'boolean'
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      obj

    toTerm: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      delete obj.factor
      delete obj.answer
      delete obj.isActive
      delete obj.id
      obj