async = require('async')

exports.add = (params, done)->
  if !params.name || !params.permissionaccesss
    return done({code: 5120, error: 'Role add: Missing required params (name, permissionaccesss)'}, null)
  if !_.isObject params.permissionaccesss
    params.permissionaccesss = JSON.parse params.permissionaccesss
  Role.findOne name: params.name, (err, role)->
    if err
      return done({code: 5000, error: err}, null)
    if role
      return done({code: 5119, error: 'Role add: This role name has been used'}, null)
    pas = []
    async.each params.permissionaccesss, (pa, cb)->
      PermissionAccess.findOne pa, (err, permissionaccess)->
        if err
          return cb({code: 5000, error: err})
        if permissionaccess?
          pas.push permissionaccess.id
          return cb()
        else
          PermissionAccess.create pa, (err, newpa)->
            if err
              return cb({code: 5000, error: err})
            pas.push newpa.id
            return cb()
    , (err)->
      if err
        sails.log.info err
        return done(err, null)
      params.permissionaccesss = pas
      Role.create params, (err, newrole) ->
        if err
          return done({code: 5000, error: err}, null)
        return done(null, {success:'Insert Role success'})

exports.update = (params, done)->
  Role.findOne id: params.roleID
  .populate('permissionaccesss')
  .exec (err, role) ->
    if err
      return done({code: 5000, error: err}, null)
    if role
      if params.name
        role.name = params.name
      if params.permissionaccesss
        if !_.isObject params.permissionaccesss
          params.permissionaccesss = JSON.parse params.permissionaccesss
        role.permissionaccesss.remove _.pluck(role.permissionaccesss, 'id')
      role.save (err, maybeEmptyRole)->
        if err
          return done({code: 5000, error: err}, null)
        if params.permissionaccesss
          paAdd = []
          async.each params.permissionaccesss, (pa, cb)->
            PermissionAccess.findOne pa, (err, permissionaccess)->
              if err
                return cb({code: 5000, error: err})
              if permissionaccess?
                paAdd.push permissionaccess.id
                return cb()
              else
                PermissionAccess.create pa, (err, newpa)->
                  if err
                    return cb({code: 5000, error: err})
                  paAdd.push newpa.id
                  return cb()
          , (err)->
            if err
              sails.log.info err
              return done(err, null)
            maybeEmptyRole.permissionaccesss.add paAdd
            maybeEmptyRole.save (err,newRole)->
              if err
                return done({code: 5000, error: err}, null)
              async.each newRole.permissionaccesss, (pa, cb)->
                Permission.findOne pa.permission, (err, p)->
                  if err
                    return cb(err)
                  pa.permission = p.toJSON()
                  return cb()
              , (err)->
                if err
                  return done({code: 5000, error: err}, null)
                return done(null, newRole)  
        else return done(null, maybeEmptyRole)
    else return done({code: 5118, error: 'Role does not exist'}, null)

exports.remove = (params, done)->
  Role.findOne id: params.roleID, (err, role) ->
    if err
      return done({code: 5000, error: err}, null)
    if role
      Role.destroy id: params.roleID, (err, deleted) ->
        if err
          return done({code: 5000, error: err}, null)
        return done(null, {success: 'Deleted Role success'})
    else
      return done({code: 5118, err: 'Role does not exist'})

exports.view = (params, done) ->
  Role.findOne id: params.roleID
  .populate('permissionaccesss')
  .exec (err, role) ->
    if err
      return done({code: 5000, error: err}, null)
    if role
      async.each role.permissionaccesss, (pa, cb)->
        Permission.findOne pa.permission, (err, p)->
          if err
            return cb(err)
          pa.permission = p.toJSON()
          return cb()
      , (err)->
        if err
          return done({code: 5000, error: err}, null)
        return done(null, role)
    else
      return done({code: 5118, error: 'Role does not exist'}, null)

exports.list = (done) ->
  Role.find {}
  .populate('permissionaccesss')
  .exec (err, roles) ->
    if err
      return done({code: 5000, error: err}, null)
    if roles
      async.each roles, (role, cb1)->
        async.each role.permissionaccesss, (pa, cb2)->
          Permission.findOne pa.permission, (err, p)->
            if err
              return cb2(err)
            pa.permission = p.toJSON()
            return cb2()
        , (err)->
          if err
            return cb1(err)
          return cb1()
      , (err)->
        if err
          return done({code: 5000, error: err}, null)
        return done(null, roles)
    else 
      return done({code: 5118, error: 'Role does not exist'}, null)

exports.listcombo = (done) ->
  Role.native (err, cols)->
    if err
      return done({code: 5000, error: err}, null)

    cols.find {},
      name: true
    .toArray (err, roles)->
      if err
        return done({code: 5000, error: err}, null)          
      async.each roles, (role, cb) ->
        role.id = role._id
        delete role._id
        cb()
      , (err) ->
        return done(null, roles)