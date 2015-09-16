 # GameCategory.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true

  attributes:
    parent:
      model: 'gamecategory'
      defaultsTo: null

    name:
      type: 'string'
      index: true
      unique: true

    ordering: 
      type: 'integer'
      defaultsTo: 1

    isActive:
      type: 'boolean'
      required: true
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj
