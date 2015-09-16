#Admin game Nhanh Mat Bat Hinh service

exports.list  = (params, done) ->
  if !params.sortBy || params.sortBy not in ['name', 'isActive']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10

  cond = {}
  if params.limit > 0
    cond.limit = params.limit
    cond.skip = (params.page - 1) * params.limit
  
  if params.category
    cond.category = params.category
  if params.name
    cond.name = params.name
  if params.id
    cond.id = params.id
  if params.isactive?
    cond.isActive = params.isactive
    
  NhanhMatBatHinhQuiz.find cond
  .sort(sortCond)
  .populate('question')
  .populate('answers')
  .exec (err, quizs) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.list] ERROR: could not get NhanhMatBatHinh Quiz list ... #{JSON.stringify(err)}"})

    # populate
    async.each quizs, (quiz, cb1) ->
      async.each quiz.answers, (answer, cb2) ->
        NhanhMatBatHinhAnswerItem.find answer: answer.id
        .populate('category')
        .exec (err, it) ->
          if err
            return cb2({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.list] ERROR: could not get NhanhMatBatHinhAnswerItem list ... #{JSON.stringify(err)}"})
          answer.items = it
          cb2()
      , (err) ->
        if err
          return cb1(err)
        return cb1()
    , (err) ->
      if err
        return done(err, null)
      NhanhMatBatHinhQuiz.count cond, (err, total)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.list] ERROR: could not count NhanhMatBatHinhQuiz ... #{JSON.stringify(err)}"})
        return done(null, {result: quizs, total: total})

exports.add = (params, done) ->
  NhanhMatBatHinhQuiz.findOne question: params.question, (err, quiz) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Could not get Quiz... #{JSON.stringify(err)}"})
    if quiz
      return done({code: 6041, error: 'Quiz question is existed', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Quiz question is existed"})

    ImageCategory.findOne id: params.question, (err, ic) ->
      if err || !ic
        return done({code: 6042, error: 'Could not find Image category', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Could not find Image category"})
      if typeof params.answers != 'object'
        try
          params.answers = JSON.parse(params.answers)
        catch e
          return done({code: 6002, error: 'Could not JSON.parse params.answers', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Could not JSON.parse params.answers"})
        
      # check answeritem
      async.each params.answers, (answer, cb) ->
        if _.uniq(answer.answerItems, 'category').length != answer.answerItems.length
          return cb({code: 6043, error: 'Answer Category is duplicated', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Answer Category is duplicated"})
        return cb()
      , (err) ->
        if err
          return done(err)

        NhanhMatBatHinhQuiz.create params, (err, newQuiz) ->
          if err
            return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.add] ERROR: Could not create Quiz... #{JSON.stringify(err)}"})

          return done(null, newQuiz)

exports.update = (params, done) ->
  NhanhMatBatHinhQuiz.findOne id: params.id, (err, quiz) ->
    if err || !quiz
      return done({code: 6044, error: 'Could not find quiz', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get Quiz"})
    if params.question  
      quiz.question = params.question
    cond =
      question: quiz.question
      id:
        '!': quiz.id
    NhanhMatBatHinhQuiz.findOne cond, (err, existQuiz) ->
      if err
        return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get Quiz... #{JSON.stringify(err)}"})
      if existQuiz
        return done({code: 6045, error: 'Quiz question is existed', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Quiz question is existed"})

      if params.name
        quiz.name = params.name
      if params.startDate
        if !(new Date(params.startDate)).getDate()
          return done({code: 6046, error: 'Param startdate is not datetime type', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Param startdate is not datetime type"})
        quiz.startDate = params.startDate
      if params.endDate
        if !(new Date(params.endDate)).getDate()
          return done({code: 6047, error: 'Param enddate is not datetime type', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Param enddate is not datetime type"})
        quiz.endDate = params.endDate
      if params.isActive?
        quiz.isActive = params.isActive
      if params.factor
        quiz.factor = params.factor

      quiz.save (err, upQuiz) ->
        if err
          return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not update Quiz... #{JSON.stringify(err)}"})

        async.series [
          (cb) ->
            if params.answersadd
              try
                params.answersadd = JSON.parse(params.answersadd)
              catch
                return cb({code: 6002, error: 'could not JSON.parse params answersadd', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: could not JSON.parse params answersadd"})
              async.each params.answersadd, (answer, callback) ->
                if _.uniq(answer.answerItems, 'category').length != answer.answerItems.length
                  return callback({code: 6043, error: 'Each Answers Item element must be different', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Each Answers Item element must be different"})
                return callback()
              , (err) ->
                if err
                  return cb(err)
                add.quiz = upQuiz.id for add in params.answersadd
                NhanhMatBatHinhAnswer.create params.answersadd, (err, as) ->
                  if err
                    return cb(err)
                  return cb(null)
            else
              return cb(null)
          ,
          (cb) ->
            if params.answersdel
              try
                params.answersdel = JSON.parse(params.answersdel)
              catch
                return cb({code: 6002, error: 'could not JSON.parse params answersdel', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: could not JSON.parse params answersdel"})
              async.each params.answersdel, (del, callback) ->
                NhanhMatBatHinhAnswer.destroy del, (err, result) ->
                  if err
                    return callback({code: 5000, error: err})
                  return callback()
              , (err) ->
                if err
                  return cb(err)
                return cb(null)
            else
              return cb(null)
          ,
          (cb) ->
            if params.answersupdate
              try
                params.answersupdate = JSON.parse(params.answersupdate)
              catch
                return cb({code: 6002, error: 'could not JSON.parse params answersupdate', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: could not JSON.parse params answersupdate"})
              async.each params.answersupdate, (update, callback1) ->
                if _.uniq(update.answerItems, 'category').length != update.answerItems.length
                  return callback1({code: 6043, error: 'Each Answers Item element must be different', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Each Answers Item element must be different"})
                NhanhMatBatHinhAnswer.findOne id: update.id, (err, ans) ->
                  if err
                    return callback1({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get Answer... #{JSON.stringify(err)}"})
                  delete update.id
                  if update.makeAnswerQuantity
                    ans.makeAnswerQuantity = update.makeAnswerQuantity
                  if update.rightAnswerQuantity
                    ans.rightAnswerQuantity = update.rightAnswerQuantity
                  if update.factor
                    ans.factor = update.factor
                  if update.isActive?
                    ans.isActive = update.isActive
                  ans.save (err, result) ->
                    if err
                      return callback1({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not update Answer... #{JSON.stringify(err)}"})

                    async.each update.answerItems, (item, callback2) ->
                      NhanhMatBatHinhAnswerItem.findOne id: item.id, (err, it) ->
                        if err
                          return callback2({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get AnswerItem... #{JSON.stringify(err)}"})
                        if it
                          if item.isDel
                            it.destroy()
                            return callback2()
                          else
                            if item.category
                              it.category = item.category
                            if item.zIndex
                              it.zIndex = item.zIndex
                            if item.factor
                              it.factor = item.factor
                            if item.isActive?
                              it.isActive = item.isActive
                            it.save (err, result) ->
                              if err
                                return callback2({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not update AnswerItem... #{JSON.stringify(err)}"})
                              return callback2()
                        else
                          cond =
                            answer: ans.id
                            category: item.category
                          NhanhMatBatHinhAnswerItem.findOne cond, (err, result) ->
                            if err
                              return callback2({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get AnswerItem... #{JSON.stringify(err)}"})
                            if result
                              return callback2()
                            item.answer = ans.id
                            NhanhMatBatHinhAnswerItem.create item, (err, result) ->
                              if err
                                return callback2({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not create AnswerItem... #{JSON.stringify(err)}"})
                              return callback2()
                    , (err) ->
                      if err
                        return callback1(err)
                      return callback1(null)
              , (err) ->
                  if err
                    return cb(err)
                  return cb(null)
            else
              return cb(null)

        ], (e, result) ->
          if e
            return done(e)
          NhanhMatBatHinhQuiz.findOne id: upQuiz.id
          .populate('question')
          .populate('answers')
          .exec (err, q) ->
            if err
              return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get Quiz... #{JSON.stringify(err)}"})
            async.each q.answers, (answer,cb) ->
              NhanhMatBatHinhAnswerItem.find answer: answer.id
              .populate('category')
              .exec (err, it) ->
                if err
                  return cb({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.update] ERROR: Could not get AnswerItem... #{JSON.stringify(err)}"})
                answer.items = it
                cb()
            , (err) ->
              if err
                return done(err)
              return done(null, q)            

exports.remove = (params, done) ->
  NhanhMatBatHinhQuiz.destroy id: params.id, (err, delquiz) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.remove] ERROR: Could not get Quiz... #{JSON.stringify(err)}"})
    if delquiz.length == 0
      return done({code: 6044, error: 'Could not remove Quiz', log: "[Admin_NhanhMatBatHinhQuizService.remove] ERROR: Could not remove Quiz... #{JSON.stringify(err)}"})
    return done(null,delquiz)

exports.active = (params, done) ->
  NhanhMatBatHinhQuiz.update id: params.id, {isActive: params.isActive}, (err, item) ->
    if err
      done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.active] ERROR: Could not get Quiz... #{JSON.stringify(err)}"})
    if item.length == 0
      return done({code: 6044, error: "Could not active Quiz", log: "[Admin_NhanhMatBatHinhQuizService.active] ERROR: Could not update Quiz... #{JSON.stringify(err)}"})
    return done(null,true)

exports.getTerm = (numsQuiz, done)->
  getRandomImage = (categoryId, done)->
    Image.find category: categoryId, (err, images)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.getTerm] ERROR: Could not find Image #{err}"})
      randImage = images[_.random(images.length - 1)]
      randImage.toTerm()
      return done(null, randImage)
  
  getAnswersImage = (answer, done)->
    answers = []
    NhanhMatBatHinhAnswerItem.find {isActive: true, answer: answer.id}, (err, items)->
      if err
        return done({code: 5000, error: 'Could not process', log: "[Admin_NhanhMatBatHinhQuizService.getTerm] ERROR: Could not find AnswerItem #{err}"})
      
      async.each [1..answer.makeAnswerQuantity], (i, cb)->
        randItem = items.splice(Utils.randomWithFactor(items), 1)[0].toTerm()
        getRandomImage randItem.category, (err, randImage)->
          if err
            return cb(err)
          randItem.image = randImage
          answers.push randItem
          return cb()
      , (err)->
        if err
          return done(err)
        return done(null, answers)

  term = []
  NhanhMatBatHinhQuiz.find {isActive: true}
  .exec (err, quizs)->
    if err
      return done({code: 5000, error: "could not process", log: "[Admin_NhanhMatBatHinhQuizService.getTerm] ERROR: could not get NhanhMatBatHinhQuiz... #{JSON.stringify(err)}"})

    async.each [1..numsQuiz], (i, cb)->
      randQuiz = quizs[Utils.randomWithFactor(quizs)]
      quiz = {}
      getRandomImage randQuiz.question, (err, question)->
        if err
          return cb(err)
        quiz.question = question

        NhanhMatBatHinhAnswer.find {isActive: true, quiz: randQuiz.id}, (err, answers)->
          if err
            return cb({code: 5000, error: "could not process", log: "[Admin_NhanhMatBatHinhQuizService.getTerm] ERROR: could not get NhanhMatBatHinhAnswer... #{JSON.stringify(err)}"})
          randAnswer = answers[Utils.randomWithFactor(answers)]
          quiz.rightAnswerQuantity = _.random(NhanhMatBatHinhAnswer.DEFAULT_MIN_RIGHTANS_QTY, randAnswer.rightAnswerQuantity)
          
          getAnswersImage randAnswer, (err, answers)->
            if err
              return cb(err)
            quiz.answers = answers
            term.push quiz
            return cb()
    , (err)->
      if err
        return done(err)
      return done(null, {gameCode: Game.VISIBLE_APIS.NHANH_MAT, term: term})