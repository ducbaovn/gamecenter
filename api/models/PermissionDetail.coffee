ACCESS =
  VIEW: 1
  ADD: 2
  REMOVE: 4
  UPDATE: 8

module.exports =
  schema: true
  ACCESS: ACCESS
  attributes:
    name: 
      type: 'string'
      required: true

    description:
      type: 'string'
      defaultsTo: null

    controller:
      type: 'string'
      required: true

    action:
      type: 'string'
      required: true

    permission:
      model: 'permission'
      required: true

    access:
      type: 'integer'
      required: true
      enum: _.values(ACCESS)

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      return obj