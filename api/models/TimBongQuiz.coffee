DEFAULT_ANSWER_QTY = 3

module.exports =
  schema: true
  DEFAULT_ANSWER_QTY: DEFAULT_ANSWER_QTY
  attributes:
    name:
      type: 'string'
      required: true

    answers:
      collection: 'TimBongAnswer'
      via: 'quiz'

    isActive:
      type: 'boolean'
      defaultsTo: true

    activeFrom:
      type: 'datetime'

    activeTo:
      type: 'datetime'

    factor:
      type: 'float'
      defaultsTo: 1

    answerQty:
      type: 'integer'
      defaultsTo: DEFAULT_ANSWER_QTY

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj

  afterDestroy: (destroyedQuiz, next)->
    async.each destroyedQuiz, (quiz, cb)->
      TimBongAnswer.destroy quiz: quiz.id, (err, success)->
        if err
          return cb(err)
        return cb()
    , (err)->
      if err
        sails.log.info err
        return next(err)
      return next()