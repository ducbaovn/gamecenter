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

  TimBongQuiz.find cond
  .sort(sortCond)
  .populate('answers')
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.list] ERROR: could not get TimBongQuiz list ... #{JSON.stringify(err)}"})
    result = [] 
    async.each quizs, (quiz, cb)->
      BrainAdmin_TimBongAnswerService.list quiz: quiz.id
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
      TimBongQuiz.count cond, (err, total)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.list] ERROR: could not count TimBongQuiz list ... #{JSON.stringify(err)}"})
        return done(null, {result: result, total: total})

exports.add = (params, done)->
  if !params.name || !params.answers
    return done({code: 6028, error: 'Missing required params (name, answers)', log: '[BrainAdmin_TimBongQuizService.add] ERROR: Missing required params (name, answers)'})
  if typeof params.answers != 'object'
    try
      params.answers = JSON.parse params.answers
    catch
      return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_TimBongQuizService.add] ERROR: could not JSON.parse params.answers'})
  
  params.answerQty = params.answerQty || TimBongQuiz.DEFAULT_ANSWER_QTY
  if params.answers.length < params.answerQty
    return done({code: 6029, error: "Not enough answers (must equals to #{params.answerQty})", log: "[BrainAdmin_TimBongQuizService.add] ERROR: Not enough answers (must equals to #{params.answerQty})"})
  
  if params.answers.length != _.uniq(params.answers, 'image').length
    return done({code: 6025, error: 'Answer Image is duplicated', log: '[BrainAdmin_TimBongAnswerService.add] ERROR: Answer Image is duplicated'})
  TimBongQuiz.findOne name: params.name, (err, quiz)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.add] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
    if quiz
      return done({code: 6030, error: 'This name has been used', log: '[BrainAdmin_TimBongQuizService.add] ERROR: This name has been used'})
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
    TimBongQuiz.create quizData, (err, newQuiz) ->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.add] ERROR: could not create TimBongQuiz... #{JSON.stringify(err)}"})
      async.each params.answers, (answerData, cb)->
        answerData.quiz = newQuiz.id
        BrainAdmin_TimBongAnswerService.add answerData, (err, answer)->
          if err
            return cb(err)
          return cb()
      , (err)->
        if err
          return done(err, null)   
        return done(null, {success: 'Add quiz success'})

exports.remove = (params, done)->
  if !params.id
    return done({code: 6045, error: "Missing params id", log: "[BrainAdmin_TimBongQuizService.remove] ERROR: Missing params id"})
  TimBongQuiz.findOne id: params.id, (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.remove] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
    if quiz
      TimBongQuiz.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.remove] ERROR: could not remove TimBongQuiz... #{JSON.stringify(err)}"})
        return done(null, {success: 'Deleted Quiz success'})
    else
      return done({code: 6031, err: 'This Quiz does not exist', log: '[BrainAdmin_TimBongQuizService.remove] ERROR: This Quiz does not exist'})

exports.update = (params, done)->
  if !params.id
    return done({code: 6045, error: "Missing params id", log: "[BrainAdmin_TimBongQuizService.update] ERROR: Missing params id"})
  TimBongQuiz.findOne id: params.id
  .populate 'answers'
  .exec (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.update] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
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
            return done({code: 6002, error: 'could not JSON.parse params.remove', log: '[BrainAdmin_TimBongQuizService.update] ERROR: could not JSON.parse params.remove'})
        for answerRemove in params.remove
          quiz.answers.remove(answerRemove)
      
      params.answers = params.answers || []
      params.add = params.add || []
      if typeof params.answers != 'object'
        try
          params.answers = JSON.parse params.answers
        catch
          return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_TimBongQuizService.update] ERROR: could not JSON.parse params.answers'})
      if typeof params.add != 'object'
        try
          params.add = JSON.parse params.add
        catch
          return done({code: 6002, error: 'could not JSON.parse params.add', log: '[BrainAdmin_TimBongQuizService.update] ERROR: could not JSON.parse params.add'})

      if !_.every(params.add, 'image')
        return done({code: 6054, error: 'Missing Answer Image in params.add', log: '[BrainAdmin_TimBongQuizService.update] ERROR: Missing Answer Image in params.add'})
      if !_.every(params.add, 'shadowImage')
        return done({code: 6055, error: 'Missing Answer Shadow Image in params.add', log: '[BrainAdmin_TimBongQuizService.update] ERROR: Missing Answer Shadow Image in params.add'})

      newAnswers = params.answers.concat(params.add)
      if _.uniq(newAnswers, 'image').length != newAnswers.length
        return done({code: 6025, error: 'Answer Image is duplicated or existed', log: '[BrainAdmin_TimBongQuizService.update] ERROR: Answer Image is duplicated or existed'})

      quiz.answers.add(params.add)
      
      existCond =
        name: quiz.name
        id:
          '!': quiz.id
      TimBongQuiz.findOne existCond, (err, existQuiz)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.update] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
        if existQuiz?
          return done({code: 6030, error: 'This name has been used', log: '[BrainAdmin_TimBongQuizService.update] ERROR: This name has been used'})
        
        quiz.save (err, newQuiz)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.update] ERROR: could not update TimBongQuiz... #{JSON.stringify(err)}"})
          if params.remove
            TimBongAnswer.destroy id: params.remove, (err, destroy)->
              if err
                sails.log.info "[BrainAdmin_TimBongQuizService.update] ERROR: could not remove TimBongAnswer... #{JSON.stringify(err)}"
          if params.answers[0]
            async.each params.answers, (answer, cb)->
              BrainAdmin_TimBongAnswerService.update answer, (err, newAnswer)->
                if err
                  return cb(err)
                return cb()
            , (err)->
              if err
                return done(err, null)
              BrainAdmin_TimBongAnswerService.list quiz: newQuiz.id, (err, answers)->
                if err
                  return done(err, null)
                newQuiz.answers = answers
                return done(null, newQuiz)
          else return done(null, newQuiz)
    else return done({code: 6031, error: 'This Quiz does not exist', log: '[BrainAdmin_TimBongQuizService.update] ERROR: This Quiz does not exist'})

exports.getTerm = (numsQuiz, done)->  
  term = []
  TimBongQuiz.find {isActive: true}
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.getTerm] ERROR: could not get TimBongQuiz... #{JSON.stringify(err)}"})
    async.each [1..numsQuiz], (i, cb)->
      randQuiz = quizs[Utils.randomWithFactor(quizs)]
      TimBongAnswer.find {isActive: true, quiz: randQuiz.id}
      .exec (err, answers)->
        if err
          return cb({code: 5000, error: "could not process", log: "[BrainAdmin_TimBongQuizService.getTerm] ERROR: could not get TimBongAnswer... #{JSON.stringify(err)}"})
        j = 0
        quiz = {items: []}
        while j < randQuiz.answerQty
          randAnswer = answers.splice(Utils.randomWithFactor(answers), 1)[0]
          quiz.items.push randAnswer.toTerm()
          j++
        term.push quiz
        return cb()
    , (err)->
      if err
        return done(err, null)
      return done(null, {gameCode: Game.VISIBLE_APIS.TIM_BONG, term: term})