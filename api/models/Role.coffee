module.exports =
  schema: true
  attributes:
    
    name:
      type: 'string'
      required: true
      unique: true
    
    permissionaccesss:
      collection: 'permissionaccess'
      via: 'roles'

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      return obj