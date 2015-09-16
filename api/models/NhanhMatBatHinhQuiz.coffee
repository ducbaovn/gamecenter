module.exports =
  schema: true
  autoCreateAt: true
  autoUpdateAt: true

  attributes:
    name:
      type: 'string'

    question:
      model: 'ImageCategory'
      required: true

    answers:
      collection: 'NhanhMatBatHinhAnswer'
      via: 'quiz'

    startDate:
      type: 'datetime'

    endDate:
      type: 'datetime'

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
    NhanhMatBatHinhAnswer.destroy quiz: _.pluck(values, 'id'), (err, result) ->
      if err
        return next(err)
      next()