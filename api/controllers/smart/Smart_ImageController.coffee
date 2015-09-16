module.exports =
  list: (req, resp) =>
    params = 
      version: req.param('version')

    ImageService.list params, (err, result) ->
      if err
        sails.log.info err.log
        return res.badRequest({code: err.code, error: err.error})
      return resp.ok(result)