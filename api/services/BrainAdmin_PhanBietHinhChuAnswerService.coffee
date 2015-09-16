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
  PhanBietHinhChuAnswer.find cond
  .sort(sortCond)
  .populate('image')
  .populate('textImage')
  .exec (err, answers)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.list] ERROR: could not get PhanBietHinhChuAnswer list ... #{JSON.stringify(err)}"})
    # PhanBietHinhChuAnswer.count cond, (err, total)->
    #   if err
    #     sails.log.error "[BrainAdmin_PhanBietHinhChuAnswerService.list] ERROR: could not count PhanBietHinhChuAnswer list ... #{JSON.stringify(e)}"
    #     return done({code: 5000, error: "could not process"}, null)
    return done(null, answers)

exports.add = (params, done)->
    if !params.quiz || !params.image || !params.textImage
      return done({code: 6014, error: 'Missing required params (quiz, image, textImage)', log: '[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: Missing required params (quiz, image, textImage)'})
    PhanBietHinhChuQuiz.findOne id: params.quiz, (err, quiz)->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: could not get PhanBietHinhChuQuiz ... #{JSON.stringify(err)}"})
      if !quiz
        return done({code: 6015, error: 'Quiz is not found', log: "[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: Quiz not found"})
      cond =
          quiz: params.quiz
          image: params.image
      PhanBietHinhChuAnswer.findOne cond, (err, answer)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: could not get PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
        if answer
          return done({code: 6016, error: 'Answer Image is existed', log: '[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: Answer Image is existed'})
        PhanBietHinhChuAnswer.create params, (err, newAnswer)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.add] ERROR: could not create PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
          return done(null, newAnswer)

exports.remove = (params, done)->
  PhanBietHinhChuAnswer.findOne id: params.id, (err, answer) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.remove] ERROR: could not get PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
    if answer
      PhanBietHinhChuAnswer.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.remove] ERROR: could not remove PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
        return done(null, {success: 'Deleted Answer success'})
    else
      return done({code: 6017, err: 'This Answer does not exist', log: "[BrainAdmin_PhanBietHinhChuAnswerService.remove] ERROR: This Answer does not exist"})

exports.update = (params, done)->
  PhanBietHinhChuAnswer.findOne id: params.id, (err, answer) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: could not get PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
    if answer
      if params.quiz
        answer.quiz = params.quiz
      PhanBietHinhChuQuiz.findOne answer.quiz, (err, quiz)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: could not get PhanBietHinhChuQuiz ... #{JSON.stringify(err)}"})
        if !quiz
          return done({code: 6018, error: 'Quiz not existed', log: '[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: Quiz not existed'})
        if params.image
          answer.image = params.image
        if params.textImage
          answer.textImage = params.textImage
        cond =
          quiz: quiz.id
          image: answer.image
          id:
            '!': answer.id
        PhanBietHinhChuAnswer.findOne cond, (err, existAnswer)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: could not get PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
          if existAnswer
            return done({code: 6016, error: 'Answer Image is duplicated or existed', log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: Answer Image is duplicated or existed"})
          if params.isActive?
            answer.isActive = params.isActive
        answer.save (err, updated)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: could not update PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
          PhanBietHinhChuAnswer.findOne id: params.id
          .populate('quiz')
          .exec (err, newAnswer)->
            if err
              return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuAnswerService.update] ERROR: could not get PhanBietHinhChuAnswer ... #{JSON.stringify(err)}"})
            return done(null, newAnswer)
    else return done({code: 6017, error: 'This Answer does not exist'}, null)
