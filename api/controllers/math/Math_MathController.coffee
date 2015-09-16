module.exports = 
  getMyInfo: (req, resp)=>
    MathService.myInfo req, (err, rt)->
      if err
        sails.log.error err
        resp.status(400).send(err)
        return
      resp.status(200).send(rt)

  descEnergyAndIncExp: (req, resp)=>
    user = req.user

    if user.energy - MathScore.ENERGY_PER_SCORE < 0
      return resp.status(400).send({code: 5044, error: 'not enough energy'})

    userEnergy = user.energy || 0
    if userEnergy > MathScore.ENERGY_PER_SCORE
      userEnergy = userEnergy - MathScore.ENERGY_PER_SCORE
    else
      userEnergy = 0

    userExp = (user.exp || 0) + MathScore.EXP_PER_SCORE

    Level.findOne exp: {'<=': userExp}
    .sort(name: 'desc')
    .exec (e, level)->
      User.update user.id, {energy: userEnergy, exp: userExp, level: level.name}, (e, us)->
        if e
          return resp.status(400).send({code: 5000, error: e})
        
        Game.findOne code:Game.VISIBLE_APIS.MATH, (e,game)->
          logData = [
            user: user
            gameCode: game.code
            category: UserLog.CATEGORY.EXP
            valueChange: MathScore.EXP_PER_SCORE
            reason: 'PLAY GAME'
          ,
            user: user
            gameCode: game.code
            category: UserLog.CATEGORY.ENERGY
            valueChange: -MathScore.ENERGY_PER_SCORE
            reason: 'PLAY GAME'
          ]
          UserLog.create logData, (e, userLog)->
            if e
              sails.log.info e

        return resp.status(200).send(us)

  postMyScore: (req, resp)=>
    MathService.updateScore req, (err, score)->
      if err
        sails.log.error err
        resp.status(400).send(JSON.stringify(err))
        return
      resp.status(200).send(score)

  myScore: (req, resp)=>
    MathScore.find {user: req.user.id}
    .sort({time: 'asc'})
    .exec (err, scores)->
      if err
        sails.log.error err
        resp.status(400).send({code: 5000, error: JSON.stringify(err)})
        return

      resp.status(200).send(scores)
  
  getChallenge: (req, resp)->
    params = req.allParams()

    ChallengeService.getChallenge params, (e, challenge)->
      if e 
        return resp.badRequest(e)

      MathChallenge.findOne {challenge: params.challengeid}, (e, mcl)->                

        if e
          return resp.badRequest({code: 5000, error: e})
        if !mcl
          return resp.badRequest({code: 5040, error: "could not found math challenge"})

        challenge.mode = mcl.mode
        challenge.operator = mcl.operator
        challenge.time = mcl.time

        resp.ok(challenge)


  addChallenge: (req, resp)=>
    MathChallengeService.addChallenge(req, resp)
    # MathChallengeService.addChallenge req, (err, challenge)->
    #   if err
    #     sails.log.error err
    #     resp.status(400).send(error: err)
    #     return
    #   resp.status(200).send(challenge.asJSON())

  stopChallenge: (req, resp)=>
    MathChallengeService.stopChallenge req, resp
    # if err
    #   sails.log.error err
    #   resp.status(400).send(error: err)
    #   return
    # resp.status(200).send(success: 'ok')


  myChallenges: (req, resp)=>
    MathChallengeService.myChallenges req, (err, challenges)->
      if err
        sails.log.error err
        resp.status(400).send(err)
        return
      resp.status(200).send(challenges)

  suggestChallenges: (req, resp)=>
    MathChallengeService.suggestChallenges req, (err, challenges)->
      if err
        sails.log.error err
        resp.status(400).send(err)
        return
      resp.status(200).send(challenges)


  acceptChallenge: (req, resp)=>
    MathChallengeService.acceptChallenge(req, resp)
    # if err
    #   sails.log.error err
    #   resp.status(400).send(error: err)
    #   return
    # resp.status(200).send(acceptance)

  postMatchScore: (req, resp)=>
    MathMatchService.postMatchScore req, (e, msg)->
      if e
        sails.log.error e
        resp.status(400).send(e)
        return
      resp.status(200).send(success: msg)

  removeScore: (req, resp)=>
    MathScore.findOne {user: req.user.id, id: req.param('scoreid')}, (e, score)->
      if e
        resp.status(400).send({code: 5000, error: e})
        return
      if ! score
        resp.status(400).send({code: 5030, error: 'not found score'})
        return
      score.destroy()
      resp.status(200).send(success: 'ok')