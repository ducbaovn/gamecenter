request = require('request')
_ = require('lodash')

webCache = require('./CacheService').webCache

WEB_API_URLS =
  sessionUrl: "#{sails.config.webapi.host}/api-request-session-key.html"
  loginUrl: "#{sails.config.webapi.host}/user/gamecenter/login"
  logoutUrl: "#{sails.config.webapi.host}/user/gamecenter/logout"
  changePasswordUrl: "#{sails.config.webapi.host}/user/gamecenter/changepassword"
  registerUrl: "#{sails.config.webapi.host}/user/gamecenter/register"
  addFriendUrl: "#{sails.config.webapi.host}/user/friend/add"
  cancelFriendUrl: "#{sails.config.webapi.host}/user/friend/cancel"
  acceptFriendUrl: "#{sails.config.webapi.host}/user/friend/accept"
  deleteFriendUrl: "#{sails.config.webapi.host}/user/friend/delete"
  listFriendsUrl: "#{sails.config.webapi.host}/user/friend/list"
  loginFbUrl: "#{sails.config.webapi.host}/user/gamecenter/login_facebook"
  registerFbUrl: "#{sails.config.webapi.host}/user/gamecenter/register_facebook"
  uploadAvatarUrl: "#{sails.config.webapi.host}/user/gamecenter/upload_avatar2"
  registerGgUrl: "#{sails.config.webapi.host}/user/gamecenter/register_google"
  loginGgUrl: "#{sails.config.webapi.host}/user/gamecenter/login_google"

getSessionKey = (done)=>
  webSession = webCache.get('webSession')
  if webSession && webSession['session_key'] && webSession['expired_time'] && webSession['expired_time'] > new Date()
    return done(null, webSession['session_key'])

  # url = 'http://fbapps.nahi.vn/api-request-session-key.html'
  url = WEB_API_URLS.sessionUrl
  request
    method: 'POST'
    uri: url
    form: {api_key: sails.config.webapi.api_key}
  , (err, res, body)->
    if err
      sails.log.error("[WEBAPI] getSessionKey: could not connect to #{url} #{JSON.stringify(err)}")
      return done(err, null)

    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      sails.log.error("[WEBAPI] getSessionKey: could not connect to #{url}: #{JSON.stringify(robj)} ")
      return done(robj.message, null)
    webCache.set('webSession', robj.result)
    done(null, robj.result.session_key)


# INPUTS:
#     access_token
#     deviceid
#     package
#     
# exports.fbLogin = (params, done)=>
#   FbService.fetchFbUser params.access_token, (err, fbUser)->
#     if err
#       return done(err, null)

#     arg =
#       email: "smfb#{fbUser.id}@facebook.com"
#       password: fbUser.id
#       deviceid: params.deviceid
#       package: params.package
#       timeout: params.timeout
#       fbToken: params.access_token

#     exports.login arg, (err, user)->
#       if err
#         # try to register a user if
#         data =
#           email: "smfb#{fbUser.id}@facebook.com"
#           password: fbUser.id
#           fullname: fbUser.name
#           gender: fbUser.gender      
#           package: params.package
#           timeout: params.timeout
#           fbToken: params.access_token
#         exports.register data, (err, user)->
#           if err
#             return done(err, null)
#           return done(null, user)
#       # return user if exist     
#       return done(null, user)

exports.fbLogin = (params, done)=>
  FbService.fetchFbUser params.access_token, (err, fbUser)->
    if err
      return done({code: 5009, error: err} , null)
    getSessionKey (err1,session_key)->
      if err1
        return done({code: 5006,error: err1},null)

      url = WEB_API_URLS.loginFbUrl
      timeoutInMins = sails.config.tokenTimeout || 30*24*60
      
      request
        method: 'POST'
        uri: url
        form: 
          session_key: session_key
          facebook_id: fbUser.id
          package: params.package
          timeout: timeoutInMins

      , (err2, res, body)->
        if err2
          sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(err2)}")
          return done({code: 5010, error: err2}, null)

        sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
        try
          robj = JSON.parse(body)
        catch
          return done({code: 5011, error: "API response is not JSON"}, null)

        if robj.status != '1000'
          if robj.status == '1007'
            noFacebookIdResponse =
              code: 5007
              error: "This email is not registered"
              data:
                email: fbUser.email || ''
                dob: fbUser.birthday || ''
                cellphone: fbUser.cellphone || ''
                fullname: fbUser.name || ''
                gender: fbUser.gender || ''
                avatar_url: if !fbUser.picture.data.is_silhouette then fbUser.picture.data.url else ''

            return done(noFacebookIdResponse, null)

          sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(robj.message)}")
          otherErrorResponse =
              code: 5016
              error: robj.message
              data: {}
          return done(otherErrorResponse, null)

        pr = _.merge(robj.result, {email: params.email, deviceid: params.deviceid, package: params.package, fbUid: fbUser.id}) 
        # need sync with db
        UserService.syncUser pr, (err, user)->
          if err
            sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
          date = new Date(robj.result.expired)
          json = {token: robj.result.token, tokenExpireAt: date}
          done(null, json)

exports.ggLogin = (params, done)=>
  GgService.fetchGgUser params.access_token, (err, ggUser)->
    if err
      return done({code: 5009, error: err}, null)

    getSessionKey (err1,session_key)->
      if err1
        return done({code: 5006, error: err1},null)

      url = WEB_API_URLS.loginGgUrl
      timeoutInMins = sails.config.tokenTimeout || 30*24*60
      
      request
        method: 'POST'
        uri: url
        form: 
          session_key: session_key
          google_id: ggUser.id
          package: params.package
          timeout: timeoutInMins

      , (err2, res, body)->
        if err2
          sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(err2)}")
          return done({code: 5010, error: err2}, null)

        sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
        try
          robj = JSON.parse(body)
        catch
          return done({code: 5011, error: "API response is not JSON"}, null)

        if robj.status != '1000'
          if robj.status == '1007'
            noFacebookIdResponse =
              code: 5007
              msg: "This email is not registered"
              data:
                email: ggUser.emails[0].value || ''
                dob: ggUser.birthday || ''
                cellphone: ggUser.cellphone || ''
                fullname: ggUser.displayName || ''
                gender: ggUser.gender || ''
                avatar_url: if !ggUser.image.isDefault then ggUser.image.url else ''

            return done(noFacebookIdResponse, null)

          sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(robj.message)}")
          otherErrorResponse =
              code: 5017
              msg: robj.message
              data: {}
          return done(otherErrorResponse, null)

        pr = _.merge(robj.result, {email: params.email, deviceid: params.deviceid, package: params.package, ggUid: ggUser.id}) 
        # need sync with db
        UserService.syncUser pr, (err, user)->
          if err
            sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
          date = new Date(robj.result.expired)
          json = {token: robj.result.token, tokenExpireAt: date}
          done(null, json)

exports.login = (params, done)=>
  getSessionKey (err1, session_key)->
    if err1
      webCache.del('webSession')
      return done({code: 5006, error: err1}, null)

    # url = 'http://fbapps.nahi.vn/user/gamecenter/login'
    url = WEB_API_URLS.loginUrl
    timeoutInMins = sails.config.tokenTimeout || 30*24*60
      
    request
      method: 'POST'
      uri: url
      form: 
        email: params.email
        password: params.password
        deviceid: params.deviceid
        package: params.package
        timeout: timeoutInMins
        session_key: session_key
    , (err, res, body)->
      if err
        sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(err)}")
        return done({code: 5010, error: err}, null)
      sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)
      catch
        return done({code: 5011, error: "API response is not JSON"}, null)
      if robj.status != '1000'
        sails.log.error("[WEBAPI] login: could not login #{url} #{JSON.stringify(robj.message)}")
        return done({code: 5015, error: robj.message}, null)

      pr = _.merge(robj.result, {email: params.email, deviceid: params.deviceid, package: params.package}) 
      # need sync with db
      UserService.syncUser pr, (err, user)->
        if err
          sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
        date = new Date(robj.result.expired)
        json = {token: robj.result.token, tokenExpireAt: date}
        done(null, json)

# logout web
exports.logout = (auth_token, done)=>
  # url = 'http://fbapps.nahi.vn/user/gamecenter/logout'
  url = WEB_API_URLS.logoutUrl
  request
    method: 'POST'
    uri: url
    form:
      type: 'MOBILE'
      token: auth_token
  , (err, res, body)->
    if err
      return done({code: 5010, error: err}, null)
      
    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done({code: 5011, error: "API response is not JSON"}, null)
    if robj.status.toString() != '1000'
      return done({code: 5018, error: robj.message}, null)

    User.update {token: auth_token}, {tokenExpireAt: new Date().addHours(-1)}, (e, user)->
      done(null, robj)


exports.changePassword = (token, old_password, new_password, done)=>
  # url = 'http://fbapps.nahi.vn/user/gamecenter/changepassword'
  url = WEB_API_URLS.changePasswordUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      old_password: old_password
      new_password: new_password
  , (err, res, body)->
    if err
      return done(err, null)
      
    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString()  != '1000'
      return done(robj.message, null)
    done(null, robj)

exports.register = (params, done)=>
  getSessionKey (err1, session_key)->
    if err1
      return done({code: 5006, error: err1}, null)
    # url = 'http://fbapps.nahi.vn/user/gamecenter/register'
    url = WEB_API_URLS.registerUrl
    timeoutInMins = sails.config.tokenTimeout || 30*24*60
    
    form =
      email: params.email
      password: params.password
      fullname: params.fullname || params.email
      cellphone: params.cellphone
      dob: params.dob
      gender: params.gender
      package: params.package
      session_key: session_key
      timeout: timeoutInMins

    request
      method: 'POST'
      uri: url
      form: form
    , (err, res, body)->
      if err
        sails.log.error("[WEBAPI] register: #{JSON.stringify(params)} ERROR #{JSON.stringify(err)}")
        return done({code: 5010, error: err}, null)

      sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)
      catch
        return done({code: 5011, error: "API response is not JSON"}, null)
      if robj.status.toString()  != '1000'
        sails.log.error("[WEBAPI] register: #{JSON.stringify(params)} ERROR #{JSON.stringify(robj.message)}")
        return done({code: 5012, error: robj.message}, null)

      pr = _.merge(robj.result, {email: params.email, deviceid: params.deviceid, package: params.package, nickname: params.nickname}) 
      # need sync with db
      UserService.syncUser pr, (err, user)->
        if err
          sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
      date = new Date(robj.result.expired)
      json = {token: robj.result.token, tokenExpireAt: date}
      done(null, json)


exports.fbRegister = (params,done)=>
  FbService.fetchFbUser params.access_token, (err, fbUser)->
    if err
      return done({code: 5009, error: err}, null)

    getSessionKey (err1, session_key)->
      if err1
        return done({code: 5006, error: err1}, null)
    
      url = WEB_API_URLS.registerFbUrl
      timeoutInMins = sails.config.tokenTimeout || 30*24*60

      form =
        session_key: session_key
        facebook_id: fbUser.id
        email: params.email
        password: params.password
        dob: params.dob || ''
        cellphone: params.cellphone || ''
        fullname: params.fullname || params.email
        gender: params.gender || '' 
        package: params.package
        timeout: timeoutInMins
        enter_email: 0

      request
        method: 'POST'
        uri: url
        form: form
      , (err2, res, body)->
        if err2
          return done({code: 5010, error: err2}, null)

        try
          robj = JSON.parse(body)
        catch
          return done({code: 5011, error: "API response is not JSON"}, null)

        if robj.status.toString()  != '1000'
          return done({code: 5013, error: robj.message}, null)

        pr = _.merge(robj.result, {
          email: params.email
          deviceid: params.deviceid
          package: params.package
          fbUid: fbUser.id
        })

        # need sync with db
        UserService.syncUser pr, (err3, user)->
          if err3
            sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
        date = new Date(robj.result.expired)
        json = {token: robj.result.token, tokenExpireAt: date}
        done(null, json)

exports.ggRegister = (params,done)=>
  GgService.fetchGgUser params.access_token, (err, ggUser)->
    if err
      return done({code: 5009, error: err}, null)

    getSessionKey (err1, session_key)->
      if err1
        return done({code: 5006, error: err1}, null)
    
      url = WEB_API_URLS.registerGgUrl
      timeoutInMins = sails.config.tokenTimeout || 30*24*60

      form =
        session_key: session_key
        google_id: ggUser.id
        email: params.email
        password: params.password
        dob: params.dob || ''
        cellphone: params.cellphone || ''
        fullname: params.fullname || params.email
        gender: params.gender || ''
        package: params.package
        timeout: timeoutInMins
        enter_email: 0

      request
        method: 'POST'
        uri: url
        form: form
      , (err2, res, body)->
        if err2
          return done({code: 5010, error: err2}, null)

        try
          robj = JSON.parse(body)
        catch
          return done({code: 5011, error: "API response is not JSON"}, null)

        if robj.status.toString()  != '1000'
          return done({code: 5014, error: robj.message}, null)

        pr = _.merge(robj.result, {
          email: params.email
          deviceid: params.deviceid
          package: params.package
          ggUid: ggUser.id
        })

        # need sync with db
        UserService.syncUser pr, (err3, user)->
          if err3
            sails.log.error("[WEBAPI] login: could not syncUser #{JSON.stringify(pr)}")
        date = new Date(robj.result.expired)
        json = {token: robj.result.token, tokenExpireAt: date}
        done(null, json)

exports.addFriend = (token, customer_id, done)=>
  # url = 'http://fbapps.nahi.vn/user/friend/add'
  url = WEB_API_URLS.addFriendUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      customer_id: customer_id
  , (err, res, body)->
    if err
      retrun done(err, null)

    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      return done(robj.message, null)
    done(null, robj)

exports.cancelFriend = (token, id, done)=>
  # url = 'http://fbapps.nahi.vn/user/friend/cancel'
  url = WEB_API_URLS.cancelFriendUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      id: id
  , (err, res, body)->
    if err
      retrun done(err, null)

    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      return done(robj.message, null)
    done(null, robj)

exports.appectFriend = (token, id, done)=>
  # url = 'http://fbapps.nahi.vn/user/friend/appect'
  url = WEB_API_URLS.acceptFriendUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      id: id
  , (err, res, body)->
    if err
      retrun done(err, null)

    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      return done(robj.message, null)
    done(null, robj)

exports.deleteFriend = (token, id, done)=>
  # url = 'http://fbapps.nahi.vn/user/friend/delete'
  url = WEB_API_URLS.deleteFriendUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      id: id
  , (err, res, body)->
    if err
      retrun done(err, null)

    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      return done(robj.message, null)
    done(null, robj)

exports.listFriends = (token, search, limit, offset, done)=>
  # url = 'http://fbapps.nahi.vn/user/friend/list'
  url = WEB_API_URLS.listFriendsUrl
  request
    method: 'POST'
    uri: url
    form:
      token: token
      search: search
      limit: limit
      offset: offset
  , (err, res, body)->
    if err
      retrun done(err, null)

    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      return done(robj.message, null)
    done(null, robj.result)


exports.uploadAvatar = (params, done)->
  url = WEB_API_URLS.uploadAvatarUrl

  request
    method: 'POST'
    uri: url
    form:
      token: params.token
      avatar: params.avatar
      file_name: params.filename
  , (err, res, body)->
    if err
      return done({code: 5010, error: err}, null)

    sails.log.info("[WEBAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)
    catch
      return done({code: 5011, error: "API response is not JSON"}, null)
    if robj.status.toString() != '1000'
      return done({code: 5022, error: robj.message}, null)
    done(null, true)
