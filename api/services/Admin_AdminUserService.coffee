bcrypt = require('bcrypt')

exports.add = (params, done)->
  if !params.email || !params.password || !params.role
    return done({code: 5115, error: 'Admin Insert: Missing required params (email, password, role)'}, null)
  AdminUser.findOne email: params.email, (err, adminuser)->
    if err
      return done({code: 5000, error: err}, null)
    if adminuser
      return done({code: 5116, error: 'Admin Insert: This email has been used'}, null)
    AdminUser.create params, (err, adminuser) ->
      if err
        return done({code: 5000, error: err}, null)
      return done(null, {success:'Insert Admin success'})

exports.update = (params, done)->
  AdminUser.findOne id: params.id, (err, adminuser) ->
    if err
      return done({code: 5000, error: err}, null)
    if adminuser
      if params.name
        adminuser.name = params.name
      if params.email
        adminuser.email = params.email
      if params.roleID
        adminuser.role = params.roleID
      if params.isActive?
        adminuser.isActive = params.isActive
      if params.password
        adminuser.newPassword = params.password
      adminuser.save (err, adminuser)->
        if err
          return done({code: 5000, error: err}, null)
        Role.findOne id: adminuser.role.id
        .populate('permissionaccesss')
        .exec (err, role)->
          if err
            return done({code: 5000, error: err}, null)
          async.each role.permissionaccesss, (pa, cb)->
            Permission.findOne pa.permission, (err, p)->
              if err
                return cb(err)
              pa.permission = p.toJSON()
              return cb()
          , (err)->
            if err
              return done({code: 5000, error: err}, null)
            adminuser = adminuser.toJSON()
            adminuser.role = role.toJSON()
            return done(null, adminuser)
    else return done({code: 5117, error: 'Admin User does not exist'}, null)

exports.remove = (params, done)->
  AdminUser.findOne id: params.id, (err, adminuser) ->
    if err
      return done({code: 5000, error: err}, null)
    if adminuser
      AdminUser.destroy id: adminuser.id, (err, deleted) ->
        if err
          return done({code: 5000, error: err}, null)
        return done(null, {success: 'Deleted Admin success'})
    else
      return done({code: 5117, err: 'Admin User does not exist'})

exports.profile = (params, done) ->
  AdminUser.findOne id: params.id
  .populate('role')
  .exec (err, adminuser) ->    
    if err
      return done({code: 5000, error: err}, null)
    if adminuser
      Role.findOne id: adminuser.role.id
      .populate('permissionaccesss')
      .exec (err, role)->
        if err
          return done({code: 5000, error: err}, null)
        async.each role.permissionaccesss, (pa, cb)->
          Permission.findOne pa.permission, (err, p)->
            if err
              return cb(err)
            pa.permission = p.toJSON()
            return cb()
        , (err)->
          if err
            return done({code: 5000, error: err}, null)
          adminuser = adminuser.toJSON()
          adminuser.role = role.toJSON()
          return done(null, adminuser)
    else 
      return done({code: 5117, error: 'Admin User does not exist'}, null)

exports.list = (params, done) ->  
  # build sort condition
  if !params.sortBy || params.sortBy not in ['name', 'email']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # build condition  
  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10
  
  cond = {}
    
  if params.filter
    cond.or = [
      name:
        contains: params.filter
    ,
      email:
        contains: params.filter
    ]

  if params.limit > 0
    cond.limit = params.limit
    cond.skip = params.limit * (params.page - 1)

  AdminUser.find cond
  .sort(sortCond)
  .populate('role')
  .exec (err, adminusers)->
    if err
      sails.log.error "[AdminUserService.list] ERROR: could not get adminuser list ... #{JSON.stringify(e)}"
      return done({code: 5000, error: "could not process"}, null)

    AdminUser.count cond, (err, total)->
      if err
        sails.log.error "[AdminUserService.list] ERROR: could not count adminuser list ... #{JSON.stringify(e)}"
        return done({code: 5000, error: "could not process"}, null)

      return done(null, {result: adminusers, total: total})
