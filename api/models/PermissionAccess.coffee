 module.exports =
  schema: true
  attributes:

    permission:
      model: 'permission'
      required: true
    
    access:
      type: 'integer'
      required: true
      min: 0
      max: 15

    roles:
      collection: 'role'
      via: 'permissionaccesss'

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      return obj