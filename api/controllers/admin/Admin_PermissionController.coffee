module.exports =
  list: (req, res) ->
    Admin_PermissionService.list (err, permission) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(permission)