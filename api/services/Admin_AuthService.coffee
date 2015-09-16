exports.login = (params, done) ->
  if !params.email || !params.password
    return done({code: 5114, error: 'Admin Login: Missing required params'})
  AdminUser.findOne email: params.email, (err, adminuser) ->
    if err
      return done({code: 5000, error: err}, null)
    if adminuser
      if !adminuser.isActive
        return done({code: 5124, err: 'Your Admin is not active.'})
      adminuser.validPassword params.password, (err, res) ->
        if err
          return done({code:5000, error: err}, null)
        if res
          return done(null, adminuser)
        return done({code:5113, error: 'Admin Login: Login Failed'}, null) 
    else return done({code:5113, error: 'Admin Login: Login Failed'}, null)

exports.isPermitted = (req, adminuser, done) ->
  if req.options.controller == 'admin/admin_adminuser' && (req.options.action == 'profile' || req.options.action == 'updateme')
    return done(null, true)
  Role.findOne id: adminuser.role.id
  .populate('permissionaccesss')
  .exec (err, role)->
    if err
      return done({code: 5000, error: err}, null)
    PermissionDetail.find controller: req.options.controller, action: req.options.action
    .exec (err, pds)->
      if err
        return done({code: 5000, error: err}, null)
      if !pds[0]
        return done(null, false)
      for pd in pds
        pa = _.find role.permissionaccesss, permission: pd.permission
        if (pa.access & pd.access)
          return done(null, true)
      return done(null, false)