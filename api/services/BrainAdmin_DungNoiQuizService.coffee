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
  if params.id?
    cond.id = params.id

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)

  DungNoiQuiz.find cond
  .sort(sortCond)
  .populate('questions')
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.list] ERROR: could not get DungNoiQuiz list ... #{JSON.stringify(err)}"}, null)
    result = []
    async.each quizs, (quiz, cb)->
      BrainAdmin_DungNoiQuestionService.list quiz: quiz.id
      , (err, questions)->
        if err
          return cb(err)
        quiz = quiz.toJSON()
        quiz.questionarr = questions
        result.push quiz
        return cb()
    , (err)->
      if err
        return done(err, null)
      DungNoiQuiz.count cond, (err, total)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.list] ERROR: could not count DungNoiQuiz list ... #{JSON.stringify(err)}"}, null)
        return done(null, {result: result, total: total})

exports.add = (params, done)->
  if !params.name || !params.questions || !params.answers
    return done({code: 6036, error: 'Missing required params (name, questions, answers)', log: '[BrainAdmin_DungNoiQuizService.add] ERROR: Missing required params (name, questions, answers)'}, null)

  if typeof params.answers != 'object'
    try
      params.answers = JSON.parse params.answers
    catch
      return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_DungNoiQuizService.add] ERROR: could not JSON.parse params.answers'})
  if typeof params.questions != 'object'
    try
      params.questions = JSON.parse params.questions
    catch
      return done({code: 6002, error: 'could not JSON.parse params.questions', log: '[BrainAdmin_DungNoiQuizService.add] ERROR: could not JSON.parse params.questions'})
  params.answerQty = params.answerQty || DungNoiQuiz.DEFAULT_ANSWER_QTY
  
  if params.answers.length < params.answerQty
    return done({code: 6037, error: "Not enough answers (must equals to #{params.answerQty})", log: "[BrainAdmin_DungNoiQuizService.add] ERROR: Not enough answers (must equals to #{params.answerQty})"}, null)
  
  if params.answers.length != _.uniq(params.answers, 'id').length
    return done({code: 6038, error: 'Answer Image is duplicated', log: "[BrainAdmin_DungNoiQuizService.add] ERROR: Answer Image is duplicated"}, null)

  if params.questions.length != _.uniq(params.questions, 'image').length
    return done({code: 6034, error: 'Question Image is duplicated', log: "[BrainAdmin_DungNoiQuizService.add] ERROR: Question Image is duplicated"}, null)

  DungNoiQuiz.findOne name: params.name, (err, quiz)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.add] ERROR: could not get DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
    if quiz?
      return done({code: 6039, error: 'This name has been used', log: '[BrainAdmin_DungNoiQuizService.add] ERROR: This name has been used'}, null)

    data = _.clone(params)
    delete data.questions

    DungNoiQuiz.create data, (err, newQuiz) ->
      if err
        return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.add] ERROR: could not create DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
      async.each params.questions, (question,cb) ->
        question.quiz = newQuiz.id
        BrainAdmin_DungNoiQuestionService.add question, (err, newQuestion) ->
          if err
            return cb(err)
          return cb()
      , (err) ->
        if err
          return done(err, null)
        return done(null, newQuiz)

exports.remove = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_DungNoiQuizService.remove] ERROR: Missing params id"})
  DungNoiQuiz.findOne id: params.id, (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.remove] ERROR: could not get DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
    if quiz
      DungNoiQuiz.destroy id: params.id, (err, deleted) ->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.remove] ERROR: could not remove DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
        return done(null, {success: 'Deleted Quiz success'})
    else
      return done({code: 6040, err: 'This Quiz does not exist', log: '[BrainAdmin_DungNoiQuizService.remove] ERROR: This Quiz does not exist'})

exports.update = (params, done)->
  if !params.id
    return done({code: 6048, error: "Missing params id", log: "[BrainAdmin_DungNoiQuizService.update] ERROR: Missing params id"})
  DungNoiQuiz.findOne id: params.id
  .populate 'questions'
  .exec (err, quiz) ->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.update] ERROR: could not get DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
    if quiz
      if params.name
        quiz.name = params.name
      if params.code
        quiz.code = params.code
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
            return done({code: 6002, error: 'could not JSON.parse params.remove', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: could not JSON.parse params.remove'})
        for answerRemove in params.remove
          quiz.questions.remove(answerRemove)

      params.questions = params.questions || []
      params.add = params.add || []
      if typeof params.questions != 'object'
        try
          params.questions = JSON.parse params.questions
        catch
          return done({code: 6002, error: 'could not JSON.parse params.questions', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: could not JSON.parse params.questions'})
      if typeof params.add != 'object'
        try
          params.add = JSON.parse params.add
        catch
          return done({code: 6002, error: 'could not JSON.parse params.add', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: could not JSON.parse params.add'})

      if !_.every(params.add, 'image')
        return done({code: 6056, error: 'Missing Question Image in params.add', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: Missing Question Image in params.add'})
      if !_.every(params.add, 'rightAnswer')
        return done({code: 6057, error: 'Missing Question Right Image in params.add', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: Missing Question right Image in params.add'}) 

      newQuestions = params.questions.concat(params.add)
      if _.uniq(newQuestions, 'image').length != newQuestions.length
        return done({code: 6034, error: 'Question Image is duplicated', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: Question Image is duplicated'})
      quiz.questions.add(params.add)

      if params.answerQty
        quiz.answerQty = params.answerQty
      if params.answers
        if typeof params.answers != 'object'
          try
            params.answers = JSON.parse params.answers
          catch
            return done({code: 6002, error: 'could not JSON.parse params.answers', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: could not JSON.parse params.answers'})
        quiz.answers = params.answers

      if quiz.answers.length < quiz.answerQty
        return done({code: 6037, error: 'Not enough Answer Image', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: Not enough Answer Image'})
      
      if quiz.answers.length != _.uniq(quiz.answers, 'id').length
        return done({code: 6038, error: 'Answer Image is duplicated', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: Answer Image is duplicated'})
  
      existCond =
        name: quiz.name
        id:
          '!': quiz.id
      DungNoiQuiz.findOne existCond, (err, existQuiz)->
        if err
          return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.update] ERROR: could not get DungNoiQuiz... #{JSON.stringify(err)}"})
        if existQuiz?
          return done({code: 6039, error: 'This name has been used', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: This name has been used'})
      
        quiz.save (err, newQuiz)->
          if err
            return done({code: 5000, error: "could not process", log: "[BrainAdmin_DungNoiQuizService.update] ERROR: could not update DungNoiQuiz ... #{JSON.stringify(err)}"}, null)
          if params.remove
            DungNoiQuiz.destroy params.remove, (err)->
              if err
                sails.log.info "[BrainAdmin_DungNoiQuizService.update] ERROR: could not remove DungNoiAnswer... #{JSON.stringify(err)}"
          if params.questions[0]
            async.each params.questions, (question, cb)->
              BrainAdmin_DungNoiQuestionService.update question, (err, newQuestion)->
                if err
                  return cb(err)
                return cb()
            , (err)->
              if err
                return done(err, null)
              BrainAdmin_DungNoiQuestionService.list quiz: newQuiz.id, (err, questions)->
                if err
                  return done(err, null)
                newQuiz.questions = questions
                return done(null, newQuiz)
          else return done(null, newQuiz)
    else return done({code: 6040, error: 'This Quiz does not exist', log: '[BrainAdmin_DungNoiQuizService.update] ERROR: This Quiz does not exist'}, null)

exports.getTerm = (numsQuiz, done)->
  shuffle = (array)->
    currentIndex = array.length

    while (0 != currentIndex)
      randomIndex = Math.floor(Math.random() * currentIndex)
      currentIndex -= 1

      temporaryValue = array[currentIndex]
      array[currentIndex] = array[randomIndex]
      array[randomIndex] = temporaryValue
    return _.cloneDeep(array)

  term = []
  DungNoiQuiz.find {isActive: true}
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.getTerm] ERROR: could not get PhanBietHinhChuQuiz... #{JSON.stringify(err)}"})
    
    async.each [1..numsQuiz], (i, cb)->
      randQuiz = quizs[Utils.randomWithFactor(quizs)]
      DungNoiQuestion.find {isActive: true, quiz: randQuiz.id}
      .exec (err, questions)->
        if err
          return cb({code: 5000, error: "could not process", log: "[BrainAdmin_PhanBietHinhChuQuizService.getTerm] ERROR: could not get PhanBietHinhChuAnswer... #{JSON.stringify(err)}"})
        randQuestion = questions[Utils.randomWithFactor(questions)].toTerm()
        quiz = {answers: shuffle(randQuiz.answers), question: randQuestion}
        term.push quiz
        return cb()
    , (err)->
      if err
        return done(err, null)
      return done(null, {gameCode: Game.VISIBLE_APIS.DUNG_NOI, term: term})