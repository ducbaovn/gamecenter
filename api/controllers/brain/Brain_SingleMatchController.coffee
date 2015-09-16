###
  @api {post} /brain/single/start Start Game
  @apiName Start Game
  @apiGroup 1. Single

  @apiParam {Array} gameList Array of Game Code in Brain War.
  @apiParam {Integer} time Time which Game will be played in (second).

  @apiSuccess {JSON} user User Information.
  @apiSuccess {Array} terms Array of Game Term.

  @apiSuccessExample Success-Response:
    HTTP/1.1 200 OK
    {
      user:
        "fbUid": null,
        "fbToken": null,
        "token": "fcc99691b81d4fbedfeb4b6690bcd9417f98adc53b7e42d5d2f7b62519cd1e95",
        "tokenExpireAt": "2015-05-06T10:17:54.000Z",
        "package": "werwrew",
        "webSyncedAt": "2015-04-06T10:17:54.314Z",
        "webId": "37469",
        "email": "nn@nahi.vn",
        "fullname": "nn@nahi.vn",
        "nickname": "nn@nahi.vn",
        "avatar_url": "http://fbapps.nahi.vn/media/media/upload/avatar/2015/03/13/nahi_550262f29bd0f_Forest-Runner105.png",
        "dob": "1480-08-10T17:00:00.000Z",
        "gender": "FEMALE",
        "onlineStatus": "OFFLINE",
        "exp": 100,
        "level": 1,
        "cleverExp": 0,
        "exactExp": 0,
        "logicExp": 0,
        "naturalExp": 0,
        "socialExp": 0,
        "langExp": 0,
        "starMoney": 68454,
        "rubyMoney": 0,
        "energy": 470,
        "isReal": true,
        "createdAt": "2015-01-19T10:24:59.453Z",
        "updatedAt": "2015-04-06T10:18:08.509Z",
        "socketId": "Vk7Axssnd0No7c5s5rhr",
        "id": "54bcdb7b484cd2b73dbd5c21"
      terms: [
        gameCode: 'DT01',
        term: [
          answers: [{id: 'xxx', imageUrl: 'yyy', category: 'zzz'}, {id: 'xxx', imageUrl: 'yyy', category: 'zzz'}],
          questions:
            image: 'xxx'
            rightAnswer: 'yyy'
        ,
          answers: [{id: 'xxx', imageUrl: 'yyy', category: 'zzz'}, {id: 'xxx', imageUrl: 'yyy', category: 'zzz'}],
          questions:
            rightAnswer: 'yyy'
            image: 'xxx'
        ]
      ,
        gameCode: 'DT02',
        term: [
          items: [
            image: 'xxx',
            shadowmage: 'yyy'
          ,
            image: 'xxx',
            shadowImage: 'yyy'
          ,
            image: 'xxx',
            shadowImage: 'yyy'
          ]      
        ,
          items: [
            image: 'xxx',
            shadowImage: 'yyy'
          ,
            image: 'xxx',
            shadowImage: 'yyy'
          ,
            image: 'xxx',
            shadowImage: 'yyy'
          ]      
        ]
      ,
        gameCode: 'DT03',
        term: [
          question: 'xxx',
          rightAnswerQuantity: 3,
          answers: [
            id: 'xxx',
            extends: 'yyy'
          ,
            id: 'xxx',
            extends: 'yyy'
          ,
            id: 'xxx',
            extends: 'yyy'
          ]
        ,
          question: 'xxx',
          rightAnswerQuantity: 2,
          answers: [
            id: 'xxx',
            extends: 'yyy'
          ,
            id: 'xxx',
            extends: 'yyy'
          ,
            id: 'xxx',
            extends: 'yyy'
          ]
        ]
      ,
        gameCode: 'DT04',
        term: [
          items: [
            image: 'xxx',
            textImage: 'yyy'
          ,
            image: 'xxx',
            textImage: 'yyy'
          ,
            image: 'xxx',
            textImage: 'yyy'
          ]      
        ,
          items: [
            image: 'xxx',
            textImage: 'yyy'
          ,
            image: 'xxx',
            textImage: 'yyy'
          ,
            image: 'xxx',
            textImage: 'yyy'
          ]      
        ]
      ]
    }
  @apiError code 6060 - Missing params gameList.

  @apiErrorExample Error-Response:
     HTTP/1.1 404 Not Found
     {
       "code": 6060
       "error": "Missing params gameList"
     }

  @apiError code 6062 - Not enough energy. 
###


exports.start = (req, res)->
  user = req.user
  params = req.allParams()
  userEnergy = user.energy || 0

  ConfigurationService.getConfig Game.VISIBLE_APIS.BRAIN, (err, config) ->

    if userEnergy - config.energyPerPlay < 0
      return res.status(400).send({code: 6062, error: 'not enough energy'})

    userEnergy = userEnergy - config.energyPerPlay
    userExp = (user.exp || 0) + config.expPerPlay

    if !params.gameList
      sails.log.info "[Brain_SingleMatchController.start] ERROR: Missing params gameList... #{err}"
      res.badRequest({code: 6060, error: 'Missing params gameList'})

    if typeof params.gameList != 'object'
      try
        params.gameList = JSON.parse params.gameList
      catch err
        if err
          return res.badRequest({code: 6065, error: 'Could not JSON.parse gameList'})

    # if !params.mode
    #   sails.log.info "[Brain_SingleMatchController.start] ERROR: Missing params mode... #{err}"
    #   res.badRequest({code: 6063, error: 'Missing params mode'})    

    quizPerTerm = params.time * 2 || params.score * 3 || 100
    
    LevelService.getUserLevel userExp, (err, userLevel)->
      User.update id: user.id, {energy: userEnergy, exp: userExp, level: userLevel}, (err, us)->
        if err
          sails.log.info "[Brain_SingleMatchController.start] ERROR: Could not update User... #{err}"
          return res.badRequest({code: 5000, error: 'Could not process'})
        
        BrainTermService.getTerms params.gameList, quizPerTerm, (err, terms)->
          if err
            sails.log.info err.log
            return res.badRequest({code: err.code, error: err.error})

          # if params.mode == Configuration.BRAIN_MODES.RANDOM
          return res.status(200).send(user: us, terms: terms)
          # else
          #   moneyData =
          #     star: config.starSingleMode
          #     itemid: Game.VISIBLE_APIS.BRAIN
          #     note: "Chơi game #{Game.VISIBLE_APIS.BRAIN}"
          #     gameCode: Game.VISIBLE_APIS.BRAIN
          #   MoneyService.descStars user, moneyData, (err, updatedUser)->
          #     if err
          #       sails.log.info "[Brain_SingleMatchController.start] ERROR: Could not descStars... #{err}"
          #       return res.badRequest({code: 6064, error: 'Could not descStars'})
              # return res.status(200).send(user: updatedUser, terms: terms)

        logData = [
          user: user
          gameCode: Game.VISIBLE_APIS.BRAIN
          category: UserLog.CATEGORY.EXP
          valueChange: config.expPerPlay
          reason: 'PLAY GAME'
        ,
          user: user
          gameCode: Game.VISIBLE_APIS.BRAIN
          category: UserLog.CATEGORY.ENERGY
          valueChange: -config.energyPerPlay
          reason: 'PLAY GAME'
        ]
        UserLog.create logData, (err, userLog)->
          if err
            sails.log.info err

exports.end = (req, res)->
  params = req.allParams()
  params.user = req.user
  if !params.miniGameCode || !params.score || !params.time || !params.correct || !params.wrong
    sails.log.info '[Brain_SingleMatchController.end] ERROR: Missing params'
    res.badRequest({code: 6067, error: 'Missing params'})
  BrainService.updateScore params, (err, success)->
    if err
      sails.log.info err.log
      res.badRequest(code: err.code, error: err.error)
    else
      res.status(200).send(success)

exports.getTerms = (req, res)->
  params = req.allParams()
  if !params.gameList
    sails.log.info "[Brain_SingleMatchController.getTerms] ERROR: Missing params gameList... #{err}"
    res.badRequest({code: 6060, error: 'Missing params gameList'})

  if typeof params.gameList != 'object'
    try
      params.gameList = JSON.parse params.gameList
    catch err
      if err
        return res.badRequest({code: 6065, error: 'Could not JSON.parse gameList'})

  quizPerTerm = params.time * 2 || params.score * 3 || 100

  BrainTermService.getTerms params.gameList, quizPerTerm, (err, terms)->
    if err
      sails.log.info err.log
      return res.badRequest({code: err.code, error: err.error})

    return res.status(200).send(terms: terms)