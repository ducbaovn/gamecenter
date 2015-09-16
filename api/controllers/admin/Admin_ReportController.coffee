module.exports =

  starReport: (req, res) ->
    params = req.allParams()
    params.category = UserLog.CATEGORY.STAR
    Admin_UserLogService.report params
    , (err, report) ->
      if err
        sails.log.info err
        res.badRequest(err)
      else
        res.status(200).send(report)

  energyReport: (req, res) ->
    params = req.allParams()
    params.category = UserLog.CATEGORY.ENERGY
    Admin_UserLogService.report params
    , (err, report) ->
      if err
        sails.log.info err
        res.badRequest(err)
      else
        res.status(200).send(report)

  expReport: (req, res) ->
    params = req.allParams()
    params.category = UserLog.CATEGORY.EXP
    Admin_UserLogService.report params
    , (err, report) ->
      if err
        sails.log.info err
        res.badRequest(err)
      else
        res.status(200).send(report)

  moneyReport: (req, res) ->
    params = req.allParams()
    params.category = UserLog.CATEGORY.MONEY
    Admin_UserLogService.report params
    , (err, report) ->
      if err
        sails.log.info err
        res.badRequest(err)
      else
        res.status(200).send(report)

  timeReport: (req, res) ->
    params = req.allParams()
    params.category = UserLog.CATEGORY.TIME
    Admin_UserLogService.report params
    , (err, report) ->
      if err
        sails.log.info err
        res.badRequest(err)
      else
        res.status(200).send(report)