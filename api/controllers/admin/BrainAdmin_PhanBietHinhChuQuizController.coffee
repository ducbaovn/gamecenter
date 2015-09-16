module.exports = 

  list: (req, res) ->
    params = req.allParams()
    BrainAdmin_PhanBietHinhChuQuizService.list params, (err, list) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else
        res.status(200).send list

  add: (req, res) ->
    params = req.allParams()
    BrainAdmin_PhanBietHinhChuQuizService.add params, (err, newTerm) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(newTerm)

  remove: (req, res) ->
    params = req.allParams()
    BrainAdmin_PhanBietHinhChuQuizService.remove params, (err, success) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(success)

  update: (req, res) ->
    params = req.allParams()
    BrainAdmin_PhanBietHinhChuQuizService.update params, (err, updated) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(updated)  