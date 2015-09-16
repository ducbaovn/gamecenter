async = require('async')
pDatas = [
  code: 'PG01'
  name: 'Quản lý quản trị'
  ordering: 1
,
  code: 'PG02'
  name: 'Quản lý quyền'
  ordering: 2
,
  code: 'PG03'
  name: 'Quản lý trò chơi'
  ordering: 3
,
  code: 'PG04'
  name: 'Quản lý loại trò chơi'
  ordering: 4
,
  code: 'PG05'
  name: 'Quản lý vật phẩm'
  ordering: 5
,
  code: 'PG06'
  name: 'Quản lý thông báo'
  ordering: 6
,
  code: 'PG07'
  name: 'Quản lý người dùng'
  ordering: 7
,
  code: 'PG08'
  name: 'Thống kê'
  ordering: 8
,
  code: 'PG09'
  name: 'Quản lý Đấu trí'
  ordering: 9
,
  code: 'PG10'
  name: 'Quản lý cấu hình'
  ordering: 10
]


createAdminUser = (role)=>
  data =
    name: 'superadmin'
    email: 'baodn@nahi.vn'
    password: '123456'
    role: role

  AdminUser.create data, (e, adminuser)->
    if e 
      sails.log.info e
      return false
    return true

createRole = (pas, done)=>
  data = 
    name: 'superadmin'
    permissionaccesss: pas

  Role.create data, (e, role)->
    if e 
      sails.log.info e
      return done(e, null)
    return done(null, role)

createPermission = (pDatas, done)->
  permissions = [] 
  async.each pDatas, (data, cb)->
    Permission.create data, (e, p)->
      if e 
        sails.log.info e
        return cb(e)
      permissions.push(p)
      return cb()
  , (e)->
    if e
      sails.log.info e
      return done(e, null)
    return done(e, permissions)

createPermissionAccess = (permissions, done)->
  paDatas = [
    permission: permissions[0]
    access: 15
  ,
    permission: permissions[1]
    access: 15
  ,
    permission: permissions[2]
    access: 15
  ,
    permission: permissions[3]
    access: 15
  ,
    permission: permissions[4]
    access: 15
  ,
    permission: permissions[5]
    access: 15
  ,
    permission: permissions[6]
    access: 15
  ,
    permission: permissions[7]
    access: 15
  ,
    permission: permissions[8]
    access: 15
  ,
    permission: permissions[9]
    access: 15
  ]
  pas = []
  async.each paDatas, (paData, cb)->
    PermissionAccess.create paData, (e, pa)->
      if e
        sails.log.info e
        return cb(e)
      pas.push(pa)
      return cb()
  , (e)->
    if e
      sails.log.info e
      return done(e, null)
    return done(e, pas)

createPermissionDetail = (permissions, done)->
  pdDatas = [      
    name: 'Add Admin User'
    controller: 'admin/admin_adminuser'
    action: 'add'
    permission: permissions[0]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Admin User'
    controller: 'admin/admin_adminuser'
    action: 'update'
    permission: permissions[0]
    access: PermissionDetail.ACCESS.UPDATE
  , 
    name: 'Remove Admin User'
    controller: 'admin/admin_adminuser'
    action: 'remove'
    permission: permissions[0]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Get Admin User List'
    controller: 'admin/admin_adminuser'
    action: 'list'
    permission: permissions[0]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Role'
    controller: 'admin/admin_role'
    action: 'add'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Role'
    controller: 'admin/admin_role'
    action: 'update'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'Remove Role'
    controller: 'admin/admin_role'
    action: 'remove'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'View Role Info'
    controller: 'admin/admin_role'
    action: 'view'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'List Role'
    controller: 'admin/admin_role'
    action: 'list'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'List Permission'
    controller: 'admin/admin_permission'
    action: 'list'
    permission: permissions[1]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'List Game'
    controller: 'admin/admin_game'
    action: 'list'
    permission: permissions[2]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Game'
    controller: 'admin/admin_game'
    action: 'add'
    permission: permissions[2]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Game'
    controller: 'admin/admin_game'
    action: 'update'
    permission: permissions[2]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'Remove Game'
    controller: 'admin/admin_game'
    action: 'remove'
    permission: permissions[2]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Game Status'
    controller: 'admin/admin_game'
    action: 'status'
    permission: permissions[2]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Game Category'
    controller: 'admin/admin_gamecategory'
    action: 'list'
    permission: permissions[3]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Game Category'
    controller: 'admin/admin_gamecategory'
    action: 'add'
    permission: permissions[3]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Game Category'
    controller: 'admin/admin_gamecategory'
    action: 'update'
    permission: permissions[3]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'Remove Game Category'
    controller: 'admin/admin_gamecategory'
    action: 'remove'
    permission: permissions[3]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Game Category Status'
    controller: 'admin/admin_gamecategory'
    action: 'status'
    permission: permissions[3]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List User'
    controller: 'admin/admin_user'
    action: 'list'
    permission: permissions[6]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View User'
    controller: 'admin/admin_user'
    action: 'view'
    permission: permissions[6]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'List Item'
    controller: 'admin/admin_item'
    action: 'list'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Item'
    controller: 'admin/admin_item'
    action: 'create'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Item'
    controller: 'admin/admin_item'
    action: 'update'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'View Item'
    controller: 'admin/admin_item'
    action: 'get'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Update Item Status'
    controller: 'admin/admin_item'
    action: 'status'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Notification Templates'
    controller: 'admin/admin_notificationtemplate'
    action: 'list'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Notification Template'
    controller: 'admin/admin_notificationtemplate'
    action: 'add'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Update Notification Template'
    controller: 'admin/admin_notificationtemplate'
    action: 'update'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'Remove Notification Template'
    controller: 'admin/admin_notificationtemplate'
    action: 'remove'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Active Notification Template'
    controller: 'admin/admin_notificationtemplate'
    action: 'active'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'View Star Report'
    controller: 'admin/admin_report'
    action: 'starReport'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View Energy Report'
    controller: 'admin/admin_report'
    action: 'energyReport'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View Experience Report'
    controller: 'admin/admin_report'
    action: 'expReport'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View Money Report'
    controller: 'admin/admin_report'
    action: 'moneyReport'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View Time Report'
    controller: 'admin/admin_report'
    action: 'timeReport'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Role List Combo'
    controller: 'admin/admin_role'
    action: 'listcombo'
    permission: permissions[0]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Game List Combo'
    controller: 'admin/admin_game'
    action: 'listcombo'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Game List Combo'
    controller: 'admin/admin_game'
    action: 'listcombo'
    permission: permissions[5]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Game List Combo'
    controller: 'admin/admin_game'
    action: 'listcombo'
    permission: permissions[6]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View Bucket Log'
    controller: 'admin/admin_bucketlog'
    action: 'list'
    permission: permissions[7]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'View User Bucket'
    controller: 'admin/admin_user'
    action: 'buckets'
    permission: permissions[6]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Game Brain List'
    controller: 'admin/admin_game'
    action: 'brainlist'
    permission: permissions[4]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'List Image Category'
    controller: 'admin/brainadmin_imagecategory'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Image Category'
    controller: 'admin/brainadmin_imagecategory'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Image Category'
    controller: 'admin/brainadmin_imagecategory'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Image Category'
    controller: 'admin/brainadmin_imagecategory'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Image'
    controller: 'admin/brainadmin_image'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Image'
    controller: 'admin/brainadmin_image'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Image'
    controller: 'admin/brainadmin_image'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Image'
    controller: 'admin/brainadmin_image'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Dung Noi Dung Cho Quiz'
    controller: 'admin/brainadmin_dungnoiquiz'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Dung Noi Dung Cho Quiz'
    controller: 'admin/brainadmin_dungnoiquiz'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Dung Noi Dung Cho Quiz'
    controller: 'admin/brainadmin_dungnoiquiz'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Dung Noi Dung Cho Quiz'
    controller: 'admin/brainadmin_dungnoiquiz'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Tim Bong Quiz'
    controller: 'admin/brainadmin_timbongquiz'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Tim Bong Quiz'
    controller: 'admin/brainadmin_timbongquiz'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Tim Bong Quiz'
    controller: 'admin/brainadmin_timbongquiz'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Tim Bong Quiz'
    controller: 'admin/brainadmin_timbongquiz'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Nhanh Mat Bat Hinh Quiz'
    controller: 'admin/brainadmin_nhanhmatbathinhquiz'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Nhanh Mat Bat Hinh Quiz'
    controller: 'admin/brainadmin_nhanhmatbathinhquiz'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Nhanh Mat Bat Hinh Quiz'
    controller: 'admin/brainadmin_nhanhmatbathinhquiz'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Nhanh Mat Bat Hinh Quiz'
    controller: 'admin/brainadmin_nhanhmatbathinhquiz'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'List Phan Biet Hinh Chu Quiz'
    controller: 'admin/brainadmin_phanbiethinhchuquiz'
    action: 'list'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Add Phan Biet Hinh Chu Quiz'
    controller: 'admin/brainadmin_phanbiethinhchuquiz'
    action: 'add'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.ADD
  ,
    name: 'Remove Phan Biet Hinh Chu Quiz'
    controller: 'admin/brainadmin_phanbiethinhchuquiz'
    action: 'remove'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.REMOVE
  ,
    name: 'Update Phan Biet Hinh Chu Quiz'
    controller: 'admin/brainadmin_phanbiethinhchuquiz'
    action: 'update'
    permission: permissions[8]
    access: PermissionDetail.ACCESS.UPDATE
  ,
    name: 'Xem Cấu hình'
    controller: 'admin/admin_configuration'
    action: 'get'
    permission: permissions[9]
    access: PermissionDetail.ACCESS.VIEW
  ,
    name: 'Update Cấu hình'
    controller: 'admin/admin_configuration'
    action: 'update'
    permission: permissions[9]
    access: PermissionDetail.ACCESS.UPDATE
  ]
  PermissionDetail.create pdDatas, (e, pds)->
    if e
      return done(e, null)
    return done(e, pds)

exports.execute = (cb)=>
  sails.log.info "ADMINUSER_ROLE_PERMISSION SEED EXECUTING..........................."

  Permission.count (e, cnt)->
    if e
      sails.log.info e
      return cb(false)
    if cnt == 0
      createPermission pDatas, (e, permissions)->
        if e
          sails.log.info e
          return cb(false)
        permissions = _.sortBy permissions, 'code'
        createPermissionDetail permissions, (e, pds)->
          if e
            sails.log.info e
            return cb(false)
        createPermissionAccess permissions, (e, pas)->
          if e
            sails.log.info e
            return cb(false)
          createRole pas, (e, role)->
            if e
              sails.log.info e
              return cb(false)
            createAdminUser role
    else
      newPermission = [
      ]
      Permission.create newPermission, (e, newps)->
        if e
          sails.log.info e
          return cb(false)
        Permission.find {}, (e, ps)->
          ps = _.sortBy ps, 'code'   
          newPermissionDetail = [
          ]
          PermissionDetail.create newPermissionDetail, (e, newpds)->
            if e
              return cb(false)
  cb(true)