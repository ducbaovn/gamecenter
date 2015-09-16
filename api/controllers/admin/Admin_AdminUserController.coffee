# Admin User Controller
module.exports =
  add: (req, res) ->
    params = req.allParams()
    Admin_AdminUserService.add params
    , (err, msg) ->
      if err
        res.badRequest(err)
      else 
        res.status(200).send(msg)

  update: (req, res) ->
    params = req.allParams()
    Admin_AdminUserService.update params
    , (err, msg) ->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)

  updateMe: (req, res) ->
    params = req.allParams()
    params.id = req.session.adminID
    params.roleID = null
    params.isActive = null
    Admin_AdminUserService.update params
    , (err, msg) ->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)

  remove: (req, res) ->
    Admin_AdminUserService.remove id: req.param('id')
    , (err, msg)->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)
 
  profile: (req, res) ->
    Admin_AdminUserService.profile id: req.session.adminID
    , (err, adminuser) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(adminuser)

  list: (req, res) ->
    params = req.allParams()
    Admin_AdminUserService.list params, (err, adminuser) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(adminuser)