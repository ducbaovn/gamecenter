
module.exports =
  schema: true
  attributes:
    quiz:
      model: 'DungNoiQuiz'
      via: 'questions'

    image:
      model: 'Image'
      required: true

    rightAnswer:
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
      delete obj.id
      delete obj.isActive
      delete obj.factor
      obj