request = require('request')
_ = require('lodash')

PIPE_API_URLS =
  profileUrl: "#{sails.config.webapi.host}/user/service/getprofile"

exports.getProfile = (params, done)=>
  url = PIPE_API_URLS.profileUrl
  data =
    auth_token: params.token

  request
    method: 'POST'
    uri: url
    form: data
  , (err, res, body)->
    if err
      sails.log.error("[PIPEAPI] getProfile: could not connect to #{url} #{JSON.stringify(err)}")
      return done(err, null)

    try
      robj = JSON.parse(body)
    catch
      return done("API response is not JSON", null)
      
    if robj.status.toString() != '1000'
      sails.log.error("[PIPEAPI] getProfile: could not connect to #{url}: #{JSON.stringify(robj)} ")
      return done(robj.message, null)
    done(null, robj.result)


exports.syncDesktopUser = (params, done)->
  User.findOne {webToken: params.token}, (ex, myUser)->
    if ex
      return done(ex, null)
    if myUser
      return done(null, myUser)

    exports.getProfile params, (e, webUser)->
      if e
        return done(e, null)

      User.findOne {webId: webUser.id}, (e2, user)->
        if e2
          return done(e2, null)

        if user
          user.webToken = params.token
          user.save()
          return done(null, user)

        data =
          webSyncedAt: (new Date())
          webId: webUser.id
          email: webUser.email
          fullname: "#{webUser.__first_name} #{webUser.__last_name}"
          nickname: webUser.username.toString().split('@')[0]
          avatar_url: webUser.__avatar
          webToken: params.token

        User.create data, (e3, usr)->
          if e3
            return done(e3, null)

          return done(null, usr)
