module.exports = 

  list: (req, res) ->
    params = req.allParams()
    BrainAdmin_ImageService.list params, (err, list) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(list)

  add: (req, res) ->
    params = req.allParams()
    console.log params
    BrainAdmin_ImageService.add params, (err, newItem) ->
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(newItem)

  remove: (req, res) ->
    params = req.allParams()
    BrainAdmin_ImageService.remove params, (err, success) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(success)

  update: (req, res) ->
    params = req.allParams()
    BrainAdmin_ImageService.update params, (err, updated) ->      
      if err
        sails.log.info err.log
        res.badRequest({code: err.code, error: err.error})
      else 
        res.status(200).send(updated)