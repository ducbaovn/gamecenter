exports.add = (req, res)->
  params = req.allParams()
  params.user = req.user
  ScoreService.add params, (err, result)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send result

exports.remove = (req, res)->
  params = req.allParams()
  params.user = req.user
  ScoreService.remove params, (err, result)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send result

exports.me = (req, res)->
  params = req.allParams()
  params.user = req.user
  ScoreService.me params, (err, result)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send result