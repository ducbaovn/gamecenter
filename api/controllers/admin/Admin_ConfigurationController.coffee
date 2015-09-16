
module.exports =

  get: (req, res) ->
    gamecode = req.param('gamecode')
    if !gamecode
      return res.badRequest({code: 6208, error: 'missing param game code'})

    ConfigurationService.getConfig gamecode, (err, config) ->
      if err 
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})      
      return res.ok(config)

  update: (req, res) ->    
    params = req.allParams()
    if !params.gamecode
      return res.badRequest({code: 6208, error: 'missing param game code'})
    if !params.value
      return res.badRequest({code: 6211, error: 'missing param value'})

    ConfigurationService.setConfig params.gamecode, params.value, (err, configs) ->
      if err 
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return res.ok(success: 'ok')