 module.exports =
  schema: true
  attributes:
    
    code:
      type: 'string'
      unique: true
      required: true

    name:
      type: 'string'
      unique: true
      required: true

    ordering:
      type: 'integer'

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      return obj