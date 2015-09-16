# Admin User Log
module.exports =

  view: (req, res) ->
    params = req.allParams()
    Admin_UserLogService.view params
    , (err, userLog) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(userLog)

  list: (req, res) ->
    params = req.allParams()
    Admin_UserLogService.list params, (err, usersLog) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(usersLog)
