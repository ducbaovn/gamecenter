
module.exports =
  schema: true
  attributes:
    quiz:
      model: 'TimBongQuiz'
      via: 'answers'

    image:
      model: 'Image'
      required: true

    shadowImage:
      model: 'Image'
      required: true

    isActive:
      type: 'boolean'
      defaultsTo: true

    factor:
      type: 'float'
      defaultsTo: 1

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj

    toTerm: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.quiz
      delete obj.isActive
      delete obj.factor
      delete obj.id
      obj
