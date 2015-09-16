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
  DungNoiQuestion.find cond
  .sort(sortCond)
  .populate('image')
  .populate('rightAnswer')
  .exec (err, answers)->
    if err 
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.list] ERROR: could not get DungNoiQuestion list ... #{JSON.stringify(err)}"}, null)
    # DungNoiAnswer.count cond, (err, total)->
    #   if err
    #     sails.log.error "[BrainAdmin_DungNoiAnswerService.list] ERROR: could not count DungNoiAnswer list ... #{JSON.stringify(e)}"
    #     return done({code: 5000, error: "could not process"}, null)
    return done(null, answers)

exports.add = (params, done)->
  if !params.quiz || !params.image || !params.rightAnswer
    return done({code: 6032, error: 'Missing required params (quiz, image, rightAnswer)', log: '[BrainAdmin_DungNoiQuestionService.add] ERROR: Missing required params (quiz, image, rightAnswer)'}, null)

  DungNoiQuiz.findOne id: params.quiz, (err, quiz)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.add] ERROR: could not get DungNoiQuiz list ... #{JSON.stringify(err)}"}, null)
    if !quiz
      return done({code: 6033, error: 'Quiz is not found', log: '[BrainAdmin_DungNoiQuestionService.add] ERROR: Quiz is not found'}, null)
    cond =
        quiz: params.quiz
        image: params.image
    DungNoiQuestion.findOne cond, (err, question)->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.add] ERROR: could not get DungNoiQuestion ... #{JSON.stringify(err)}"}, null)
      if question
        return done({code: 6034, error: 'Question is existed', log: '[BrainAdmin_DungNoiQuestionService.add] ERROR: Question is existed'}, null)

      DungNoiQuestion.create params, (err, newQuestion)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.add] ERROR: could not create DungNoiQuestion ... #{JSON.stringify(err)}"}, null)
        return done(null, newQuestion)

exports.remove = (params, done)->
  DungNoiQuestion.findOne id: params.id, (err, question) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.remove] ERROR: could not get DungNoiQuestion... #{JSON.stringify(err)}"}, null)
    if question
      DungNoiQuestion.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.remove] ERROR: could not remove DungNoiQuestion ... #{JSON.stringify(err)}"}, null)
        return done(null, {success: 'Deleted Question success'})
    else
      return done({code: 6035, err: 'This Question does not exist', log: "[BrainAdmin_DungNoiQuestionService.remove] ERROR: This Question does not exist"})

exports.update = (params, done)->
  DungNoiQuestion.findOne id: params.id, (err, question) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.update] ERROR: could not get DungNoiQuestion... #{JSON.stringify(err)}"}, null)
    if question
      if params.quiz
        question.quiz = params.quiz
      if params.image
        question.image = params.image
      if params.rightAnswer
        question.rightAnswer = params.rightAnswer
      if params.isActive?
        question.isActive = params.isActive
      question.save (err, updated)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.update] ERROR: could not update DungNoiQuestion ... #{JSON.stringify(err)}"}, null)
        DungNoiQuestion.findOne id: params.id
        .populate('quiz')
        .exec (err, newQuestion)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuestionService.remove] ERROR: could not get DungNoiQuestion ... #{JSON.stringify(err)}"}, null)
          return done(null, newQuestion)
    else return done({code: 6035, error: 'This Question does not exist', log: "[BrainAdmin_DungNoiQuestionService.remove] ERROR: This Question does not exist"}, null)
