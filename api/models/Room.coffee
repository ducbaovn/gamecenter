KINDS =
  PUBLIC: 'PUBLIC'
  PEER: 'PEER'
  GROUP: 'GROUP'
  MATHROOM: 'MATHROOM'  

module.exports =
  KINDS: KINDS
  attributes:
    owner:
      model: 'user'

    target:
      model: 'user'

    name:
      type: 'string'

    kind:
      type: 'string'
      required: true

    members:
      type: 'array'

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj