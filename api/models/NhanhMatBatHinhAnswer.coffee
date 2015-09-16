_ = require('lodash')

DEFAULT_MIN_RIGHTANS_QTY = 1

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  DEFAULT_MIN_RIGHTANS_QTY: DEFAULT_MIN_RIGHTANS_QTY
  
  attributes:
    answerItems:
      collection: 'NhanhMatBatHinhAnswerItem'
      via: 'answer'

    quiz:
      model: 'NhanhMatBatHinhQuiz'
      required: true

    makeAnswerQuantity:
      type: 'integer'
      required: true

    rightAnswerQuantity:
      type: 'integer'
      defaultsTo: DEFAULT_MIN_RIGHTANS_QTY

    factor:
      type: 'float'
      defaultsTo: 1

    isActive:
      type: 'boolean'
      defaultsTo: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      obj

  afterDestroy: (values, next)->
    NhanhMatBatHinhAnswerItem.destroy answer: _.pluck(values, 'id'), (err, result) ->
      if err
        return next(err)
      next()