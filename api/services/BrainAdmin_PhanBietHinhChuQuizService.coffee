async = require('async')
exports.list = (params, done) ->  
  # build sort condition
  if !params.sortBy || params.sortBy not in ['name', 'isActive']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition  
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10
  
  cond = {}
  if params.id
    cond.id = params.id

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)

  PhanBietHinhChuQuiz.find cond
  .sort(sortCond)
  .populate('answers')
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.list] ERROR: could not get PhanBietHinhChuQuiz list ... #{JSON.stringify(err)}"})
    result = [] 
    async.each quizs, (quiz, cb)->
      BrainAdmin_PhanBietHinhChuAnswerService.list quiz: quiz.id
      , (err, answers)->
        if err
          return cb(err)
        quiz = quiz.toJSON()
        quiz.answerarr = answers
        result.push quiz
        return cb()
    , (err)->
      if err
        return done(err, null)
      PhanBietHinhChuQuiz.count cond, (err, total)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.list] ERROR: could not count PhanBietHinhChuQuiz list ... #{JSON.stringify(err)}"})
        return done(null, {result: result, total: total})

exports.add = (params, done)->
  if !params.name || !params.answers
    return done({code: 6019, error: 'Missing required params (name, answers)', log: '[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: Missing required params (name, answers)'})
  if typeof params.answers != 'object'
    try
      params.answers = JSON.parse params.answers
    catch
      return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: could not JSON.parse params.answers'})
  
  params.answerQty = params.answerQty || PhanBietHinhChuQuiz.DEFAULT_ANSWER_QTY
  if params.answers.length < params.answerQty
    return done({code: 6020, error: "Not enough answers (must equals to #{params.answerQty})", log: "[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: Not enough answers (must equals to #{params.answerQty})"})
  
  if params.answers.length != _.uniq(params.answers, 'image').length
    return done({code: 6016, error: 'Answer Image is duplicated', log: '[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: Answer Image is duplicated'})
  
  PhanBietHinhChuQuiz.findOne name: params.name, (err, quiz)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
    if quiz
      return done({code: 6021, error: 'This name has been used', log: '[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: This name has been used'})
    quizData =
      name: params.name
    if params.isActive?
      quizData.isActive = params.isActive
    if params.activeFrom
      quizData.activeFrom = params.activeFrom
    if params.activeTo
      quizData.activeTo = params.activeTo
    if params.factor
      quizData.factor = params.factor
    PhanBietHinhChuQuiz.create quizData, (err, newQuiz) ->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.add] ERROR: could not create PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
      async.each params.answers, (answerData, cb)->
        answerData.quiz = newQuiz.id
        BrainAdmin_PhanBietHinhChuAnswerService.add answerData, (err, answer)->
          if err
            return cb(err)
          return cb()
      , (err)->
        if err
          return done(err, null)   
        return done(null, {success: 'Add quiz success'})

exports.remove = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_PhanBietHinhChuQuizService.remove] ERROR: Missing params id"})
  PhanBietHinhChuQuiz.findOne id: params.id, (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.remove] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
    if quiz
      PhanBietHinhChuQuiz.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.remove] ERROR: could not remove PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
        return done(null, {success: 'Deleted Quiz success'})
    else
      return done({code: 6022, err: 'This Quiz does not exist', log: '[BrainAdmin_PhanBietHinhChuQuizService.remove] ERROR: This Quiz does not exist'})

exports.update = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: Missing params id"})
  PhanBietHinhChuQuiz.findOne id: params.id
  .populate 'answers'
  .exec (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
    if quiz
      if params.name
        quiz.name = params.name
      if params.activeFrom
        quiz.activeFrom = params.activeFrom
      if params.activeTo
        quiz.activeTo = params.activeTo
      if params.isActive?
        quiz.isActive = params.isActive
      if params.factor
        quiz.factor = params.factor
      if params.remove
        if typeof params.remove != 'object'
          try
            params.remove = JSON.parse params.remove
          catch
            return done({code: 6002, error: 'could not JSON.parse params.remove', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not JSON.parse params.remove'})
        for answerRemove in params.remove
          quiz.answers.remove(answerRemove)
      
      params.answers = params.answers || []
      params.add = params.add || []
      if typeof params.answers != 'object'
        try
          params.answers = JSON.parse params.answers
        catch
          return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not JSON.parse params.answers'})
      if typeof params.add != 'object'
        try
          params.add = JSON.parse params.add
        catch
          return done({code: 6002, error: 'could not JSON.parse params.add', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not JSON.parse params.add'})
       
      if !_.every(params.add, 'image')
        return done({code: 6052, error: 'Missing Answer Image in params.add', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: Missing Answer Image in params.add'})
      if !_.every(params.add, 'textImage')
        return done({code: 6053, error: 'Missing Answer Text Image in params.add', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: Missing Answer Text Image in params.add'})
      
      newAnswers = params.answers.concat(params.add)
      if _.uniq(newAnswers, 'image').length != newAnswers.length
        return done({code: 6016, error: 'Answer Image is duplicated or existed', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: Answer Image is duplicated or existed'})

      quiz.answers.add(params.add)
      
      existCond =
        name: quiz.name
        id:
          '!': quiz.id
      PhanBietHinhChuQuiz.findOne existCond, (err, existQuiz)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
        if existQuiz?
          return done({code: 6021, error: 'This name has been used', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: This name has been used'})
      
        quiz.save (err, newQuiz)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not update PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
          if params.remove
            PhanBietHinhChuAnswer.destroy params.remove, (err)->
              if err
                sails.log.info "[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: could not remove PhanBietHinhChuAnswer... #{JSON.stringify(err)}"
          if params.answers[0]
            async.each params.answers, (answer, cb)->
              BrainAdmin_PhanBietHinhChuAnswerService.update answer, (err, newAnswer)->
                if err
                  return cb(err)
                return cb()
            , (err)->
              if err
                return done(err, null)
              BrainAdmin_PhanBietHinhChuAnswerService.list quiz: newQuiz.id, (err, answers)->
                if err
                  return done(err, null)
                newQuiz.answers = answers
                return done(null, newQuiz)
          else return done(null, newQuiz)
    else return done({code: 6022, error: 'This Quiz does not exist', log: '[BrainAdmin_PhanBietHinhChuQuizService.update] ERROR: This Quiz does not exist'})

exports.getTerm = (numsQuiz, done)->
  term = []
  PhanBietHinhChuQuiz.find {isActive: true}
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.getTerm] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
    async.each [1..numsQuiz], (i, cb)->
      randQuiz = quizs[Utils.randomWithFactor(quizs)]
      PhanBietHinhChuAnswer.find {isActive: true, quiz: randQuiz.id}
      .exec (err, answers)->
        if err
          return cb({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.getTerm] ERROR: could not get PhanBietHinhChuAnswer... #{JSON.stringify(err)}"})
        j = 0
        quiz = {items: []}
        while j < randQuiz.answerQty
          randAnswer = answers.splice(Utils.randomWithFactor(answers), 1)[0]
          quiz.items.push randAnswer.toTerm()
          j++
        quiz.items[0].textImage = quiz.items[1].textImage
        term.push quiz
        return cb()
    , (err)->
      if err
        return done(err, null)
      return done(null, {gameCode: Game.VISIBLE_APIS.PHAN_BIET, term: term})