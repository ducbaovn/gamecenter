module.exports =
  add: (req, res) ->
    params = req.allParams()
    Admin_RoleService.add params
    , (err, msg) ->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)

  update: (req, res) ->
    params = req.allParams()
    Admin_RoleService.update params
    , (err, msg) ->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)

  remove: (req, res) ->
    params = req.allParams()
    Admin_RoleService.remove params
    , (err, msg)->
      if err
        console.log err
        res.badRequest(err)
      else 
        res.status(200).send(msg)
 
  view: (req, res) ->
    params = req.allParams()
    Admin_RoleService.view params, (err, role) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(role)

  list: (req, res) ->
    Admin_RoleService.list (err, role) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(role)

  listcombo: (req, res) ->
    Admin_RoleService.listcombo (err, role) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(role)