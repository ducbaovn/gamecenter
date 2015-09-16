module.exports = 

  list: (req, res) ->
    params = req.allParams()
    BrainAdmin_DungNoiQuizService.list params, (err, list) ->      
      if err
        sails.log.info err.log
        res.badRequest(code: err.code, error: err.error)
      else 
        res.status(200).send(list)

  add: (req, res) ->
    params = req.allParams()
    BrainAdmin_DungNoiQuizService.add params, (err, newQuiz) ->      
      if err
        sails.log.info err.log
        res.badRequest(code: err.code, error: err.error)
      else 
        res.status(200).send(newQuiz)

  remove: (req, res) ->
    params = req.allParams()
    BrainAdmin_DungNoiQuizService.remove params, (err, success) ->      
      if err
        sails.log.info err.log
        res.badRequest(code: err.code, error: err.error)
      else 
        res.status(200).send(success)

  update: (req, res) ->
    params = req.allParams()
    BrainAdmin_DungNoiQuizService.update params, (err, updated) ->      
      if err
        sails.log.info err.log
        res.badRequest(code: err.code, error: err.error)
      else 
        res.status(200).send(updated)