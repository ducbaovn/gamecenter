module.exports = 

  list: (req, res) ->
    params = req.allParams()
    GameCategoryService.list params, (err, list) ->      
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(list)

  add: (req, res) ->
    params = req.allParams()
    GameCategoryService.add params, (err, newItem) ->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(success: 'ok')

  remove: (req, res) ->
    params = req.allParams()
    GameCategoryService.remove params, (err, success) ->      
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(success: 'ok')

  update: (req, res) ->
    params = req.allParams()
    GameCategoryService.update params, (err, updated) ->      
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(success: 'ok')

  status: (req, res) ->
    params = req.allParams()
    GameCategoryService.status params, (err, result) ->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(success: 'ok')
