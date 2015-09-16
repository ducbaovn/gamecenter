
module.exports =
  getConfiguration: (req, res) ->
    gamecode = req.param('gamecode')
    if !gamecode
      return res.badRequest({code: 6208, error: 'missing param game code'})

    ConfigurationService.getConfig gamecode, (err, config) ->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      
      return res.ok(config)