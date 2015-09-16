
module.exports = 
  
  add: (req, res)->
    params = req.allParams()
    params.user = req.user
    
    ChallengeService.add params, (err, challenges)->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.send(challenges)

  remove: (req, res)->
    params = req.allParams()
    params.user = req.user
    
    ChallengeService.remove params, (err, success)->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.send(success)

  myChallenges: (req, res)->
    params = req.allParams()
    params.user = req.user
    
    ChallengeService.myChallenges params, (err, challenges)->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.send(challenges)

  friendList: (req, res)->
    params = req.allParams()
    params.user = req.user
    
    ChallengeService.friendList params, (err, challenges)->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.send(challenges)

  worldList: (req, res)->
    params = req.allParams()
    params.user = req.user
    
    ChallengeService.worldList params, (err, challenges)->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.send(challenges)

  # stop: (req, res)->
  #   ChallengeService.stop req, res
    # if err
    #   sails.log.error err
    #   resp.status(400).send(error: err)
    #   return
    # resp.status(200).send(success: 'ok')

  accept: (req, res)->
    params = req.allParams()
    params.user = req.user
    if !params.challengId
      sails.log.info "[Smart_ChallengeController.accept] ERROR: Missing params.challengId"
      return res.badRequest({code: 6067, error: "Missing params"})
    ChallengeService.accept params, (err, success)->
      if err
        sails.log.info err.log
        return resp.badRequest({code: err.code, eror: err.error})
      res.send(success)

  matchResult: (req, res)->
    params = req.allParams()
    params.user = req.user

    ChallengeMatchService.result params, (err, success)->
      if err
        sails.log.info err.log
        return resp.badRequest({code: err.code, eror: err.error})
      res.send(success)