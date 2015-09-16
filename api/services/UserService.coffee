request = require('request')
clone = require('clone')
_ = require('lodash')

exports.fetchUser = (token, done)=>
  url = "#{sails.config.webapi.host}/user/gamecenter/get_profile"
  request
    method: 'POST'
    uri: url
    form:
      token: token
  , (err, res, body)->
    if err
      sails.log.error("[WEBAPI] getProfile: #{JSON.stringify(token)} ERROR #{JSON.stringify(err)}")
      return done(err, null)

    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)

    if robj.status != '1000'
      sails.log.error("[WEBAPI] getProfile: #{JSON.stringify(token)} ERROR #{JSON.stringify(robj.message)}")
      return done(robj.message, null)
    done(null, robj.result)


exports.syncWebUserWithToken = (params, done)->
  User.findOne {token: params.token}, (e, usr)->
    if e
      return done(e, null)

    if usr
      return done(null, usr)

    exports.fetchUser params.token, (e1, webUser)->
      if e1 || !webUser
        return done(e1, null)


      User.findOne {webId: webUser.id}, (e2, user)->
        if e2
          return done(e2, null)
        if user
          user.token = params.token
          user.save()
          return done(null, user)

        data = 
          token: params.token
          # tokenExpireAt: new Date(params.expired)
          webSyncedAt: (new Date())
          webId: webUser.id
          email: webUser.email
          fullname: webUser.fullname
          nickname: webUser.fullname.toString().split('@')[0]
          avatar_url: webUser.image
        if (new Date(webUser.dob)).getDate()
          data.dob = new Date(webUser.dob)
        if webUser.fullname && !data.nickname 
          data.nickname = webUser.fullname.toString().split('@')[0]

        if webUser.gender
          data.gender = webUser.gender

        User.create data, (err, u)->
          if err
            sails.log.error("[DBAPI] syncUser: create(#{JSON.stringify(data)}) ERROR #{JSON.stringify(err)}")
            return done(err, null)
          MoneyService.syncMoney u, (e)->
            sails.log.info e
          done(null, u)



# sync user with web api
# params:
#       token: tokenkey # token key to sync db
#       expired: datetime # expired time

exports.syncUser = (params, done)=>
  exports.fetchUser params.token, (err1, webUser)->
    if err1
      return done(err1, null)
    User.findOne {webId: webUser.id}, (err2, user)->
      if err2
        sails.log.error("[DBAPI] syncUser: findOne(#{JSON.stringify(webUser.id)}) ERROR #{JSON.stringify(err2)}")
        return done(err2, null)
      if user?
        user.fbUid = params.fbUid                   if params.fbUid
        user.ggUid = params.ggUid                   if params.ggUid
        user.token = params.token                   if params.token
        user.tokenExpireAt = new Date(params.expired)         if params.expired
        user.deviceid = params.deviceid             if params.deviceid
        user.package = params.package               if params.package
        user.webSyncedAt = new Date()
        user.nickname = params.nickname   if params.nickname
        user.fullname = webUser.fullname  if webUser.fullname && !user.fullname

        user.email = webUser.email        if webUser.email
        if webUser.dob && (new Date(webUser.dob)).getDate()
          user.dob = new Date(webUser.dob)

        if webUser.gender? && !user.gender?
          user.gender = webUser.gender

        user.avatar_url = webUser.image   if webUser.image
        user.save()
        MoneyService.syncMoney user, (e)->
          sails.log.info e
        return done(null, exports.myAttrs(user))

      data = 
        fbUid: params.fbUid
        ggUid: params.ggUid
        token: params.token
        tokenExpireAt: new Date(params.expired)
        deviceid: params.deviceid
        package: params.package
        webSyncedAt: (new Date())
        webId: webUser.id
        email: webUser.email
        fullname: webUser.fullname
        nickname: params.nickname
        avatar_url: webUser.image
      if (new Date(webUser.dob)).getDate()
        data.dob = new Date(webUser.dob)

      if webUser.gender
        data.gender = webUser.gender

      User.create data, (err, usr)->
        if err
          sails.log.error("[DBAPI] syncUser: create(#{JSON.stringify(data)}) ERROR #{JSON.stringify(err)}")
          return done(err, null)
        sails.log.info usr
        MoneyService.syncMoney usr, (e)->
          sails.log.info e
        done(null, exports.myAttrs(usr))

exports.getMyself = (token, done)=>
  User.findOne token: token, (err, user)->
    if err
      return done(err, null)
    done(null, exports.myAttrs(user))

exports.getProfile = (id, done)=>
  User.findOne id: id, (err, user)->
    if err
      return done({code: 5000, error: err}, null)
    if ! user?
      return done({code: 5020, error: "not found user"}, null)
    done(null, user.publicJSON())

exports.buildUser = ()=>
  user =
    id: null
    webId: null
    fullname: null
    email: null
    dob: null
    gender: null
    avatar_url: null
    token: null

exports.myAttrs = (usr)=>
  user = clone(usr)

  delete user.webId
  delete user.fbUid
  delete user.ggUid
  delete user.fbFriends
  delete user.webSyncedAt
  delete user.package
  delete user.deviceid
  delete user.createdAt
  delete user.updatedAt

  user

exports.publicAttrs = (usr)=>
  user = clone(usr)
  delete user.webId
  delete user.fbUid
  delete user.ggUid
  delete user.fbFriends
  delete user.webSyncedAt
  delete user.package
  delete user.deviceid
  delete user.token
  delete user.tokenExpireAt
  delete user.email
  delete user.email

  delete user.createdAt
  delete user.updatedAt

  user


exports.updateAvatar = (params, done)->
  if !params.avatar
    return done({code: 5021, error: 'Missing avatar image'})
  if !params.filename
    return done({code: 5021, error: 'Missing avatar file name'})

  WebService.uploadAvatar params, (e, uploadSuccess)=>
    if e
      return done(e)
    
    exports.fetchUser params.token, (e, webUser)->        
      User.update {webId: webUser.id}, {avatar_url: webUser.image}, (e, user)->
        if e 
          return done(e)
        return done(null, user[0])

exports.updateNickName = (params,done)=>
  if !params.nickname || params.nickname.trim().length == 0
    return done({code: 5023, error: 'nickname must be not null'},null)

  params.nickname = params.nickname.trim()

  if params.nickname.length < 1 || params.nickname.length > 12
    return done({code: 5024, error: 'length of Nickname no more than 12 characters'},null)

  if !params.user.nickname
    User.findOne {nickname: params.nickname}, (e, user)->
      return done({code: 5000, error: e}, null) if e
      return done({code: 5025, error: 'nickname already exists'}) if user

      return User.update {id: params.user.id}, {nickname: params.nickname}, (e, user)->
        if e
          return done({code: 5000, error: e}, null)

        return done(null, user)

  else User.findOne {nickname: params.nickname}, (e, user)->
    return done({code: 5000, error: e}, null) if e
    return done({code: 5025, error: 'nickname already exists'}) if user

    ConfigurationService.getCommonConfig (err, config) ->
      if err
        return done({code: err.code, error: err.error})

      MoneyService.verifyStarMoney params.user, config.changeNicknameCost, (isEnough)->
        return done({code: 5026, error: 'not enough money'},null) if !isEnough
      
        User.update {id: params.user.id}, {nickname: params.nickname}, (e, user)->
          if e
            return done({code: 5000, error: e}, null)

          Game.findOne code: Game.VISIBLE_APIS.SMART_PLUS, (e, game)->
            if e
              sails.log.info e
            param = 
              star: config.changeNicknameCost
              itemid: params.user.id
              note: "Đổi tên nhân vật thành: #{params.nickname}"
              gameCode: game.code

            MoneyService.descStars params.user, param, (e, usr)->
              if e
                return done(e, null)
                
              return done(null, user)


    

