module.exports = 

  list: (req, res) ->
    params = req.allParams()
    BrainAdmin_TimBongQuizService.list params, (err, list) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(list)

  add: (req, res) ->
    params = req.allParams()
    BrainAdmin_TimBongQuizService.add params, (err, newQuiz) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(newQuiz)

  remove: (req, res) ->
    params = req.allParams()
    BrainAdmin_TimBongQuizService.remove params, (err, success) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(success)

  update: (req, res) ->
    params = req.allParams()
    BrainAdmin_TimBongQuizService.update params, (err, updated) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(updated)