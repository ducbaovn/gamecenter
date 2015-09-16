async = require('async')
exports.list = (params, done) ->  
  # build sort condition
  if !params.sortBy || params.sortBy not in ['isActive']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition  
  # params.page = parseInt(params.page) || 1
  # params.limit = parseInt(params.limit) || 10
  
  cond = {}
  if params.quiz
    cond.quiz = params.quiz
  if params.isActive?
    cond.isActive = params.isActive
  if params.id
    cond.id = params.id

  # if params.limit > 0
  #   cond.limit = params.limit
  #   cond.skip = params.limit * (params.page - 1)
  TimBongAnswer.find cond
  .sort(sortCond)
  .populate('image')
  .populate('shadowImage')
  .exec (err, answers)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.list] ERROR: could not get TimBongAnswer list ... #{JSON.stringify(err)}"})
    # TimBongAnswer.count cond, (err, total)->
    #   if err
    #     sails.log.error "[BrainAdmin_TimBongAnswerService.list] ERROR: could not count TimBongAnswer list ... #{JSON.stringify(e)}"
    #     return done({code: 5000, error: "could not process"}, null)
    return done(null, answers)

exports.add = (params, done)->
  if !params.quiz || !params.image || !params.shadowImage
      return done({code: 6023, error: 'Missing required params (quiz, image, shadowImage)', log: '[BrainAdmin_TimBongAnswerService.add] ERROR: Missing required params (quiz, image, shadowImage)'})
    TimBongQuiz.findOne id: params.quiz, (err, quiz)->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.add] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
      if !quiz
        return done({code: 6024, error: 'Quiz is not found', log: '[BrainAdmin_TimBongAnswerService.add] ERROR: Quiz is not found'})
      cond =
          quiz: params.quiz
          image: params.image
      TimBongAnswer.findOne cond, (err, answer)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.add] ERROR: could not get TimBongAnswer... #{JSON.stringify(err)}"})
        if answer
          return done({code: 6025, error: 'Answer Image is existed', log: '[BrainAdmin_TimBongAnswerService.add] ERROR: Answer Image is existed'})
        TimBongAnswer.create params, (err, newAnswer)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.add] ERROR: could not create TimBongAnswer... #{JSON.stringify(err)}"})
          return done(null, newAnswer)

exports.remove = (params, done)->
  TimBongAnswer.findOne id: params.id, (err, answer) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.remove] ERROR: could not get TimBongAnswer... #{JSON.stringify(err)}"})
    if answer
      TimBongAnswer.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.remove] ERROR: could not remove TimBongAnswer... #{JSON.stringify(err)}"})
        return done(null, {success: 'Deleted Answer success'})
    else
      return done({code: 6026, err: 'This Answer does not exist', log: "[BrainAdmin_TimBongAnswerService.remove] ERROR: This Answer does not exist"})

exports.update = (params, done)->
  TimBongAnswer.findOne id: params.id, (err, answer) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.update] ERROR: could not get TimBongAnswer ... #{JSON.stringify(err)}"})
    if answer
      if params.quiz
        answer.quiz = params.quiz
      TimBongQuiz.findOne answer.quiz, (err, quiz)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.update] ERROR: could not get TimBongQuiz ... #{JSON.stringify(err)}"})
        if !quiz
          return done({code: 6027, error: 'Quiz not existed', log: '[BrainAdmin_TimBongAnswerService.update] ERROR: Quiz not existed'})
        if params.image
          answer.image = params.image
        if params.shadowImage
          answer.shadowImage = params.shadowImage
        cond =
          quiz: quiz.id
          image: params.image
          id:
            '!': answer.id
        TimBongAnswer.findOne cond, (err, existAnswer)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.update] ERROR: could not get TimBongAnswer ... #{JSON.stringify(err)}"})
          if existAnswer
            return done({code: 6025, error: 'Answer Image is duplicated or existed', log: "[BrainAdmin_TimBongAnswerService.update] ERROR: Answer Image is duplicated or existed"})
          if params.isActive?
            answer.isActive = params.isActive
        answer.save (err, updated)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.update] ERROR: could not update TimBongAnswer ... #{JSON.stringify(err)}"})
          TimBongAnswer.findOne id: params.id
          .populate('quiz')
          .exec (err, newAnswer)->
            if err
              return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongAnswerService.update] ERROR: could not get TimBongAnswer ... #{JSON.stringify(err)}"})
            return done(null, newAnswer)
    else return done({code: 6026, error: 'This Answer does not exist', log: '[BrainAdmin_TimBongAnswerService.update] ERROR: Answer not existed'})
