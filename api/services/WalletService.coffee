request = require('request')
_ = require('lodash')
webCache = require('./CacheService').webCache

WALLET_API_URLS =
  sessionUrl: "#{sails.config.walletapi.host}/service/basic/requestsession"
  pickRubyUrl: "#{sails.config.walletapi.host}/service/wallet/request_ruby"
  pickStarUrl: "#{sails.config.walletapi.host}/service/wallet/request_star"
  viewMoneyUrl: "#{sails.config.walletapi.host}/service/wallet/get_wallet"
  changeRubyToStarUrl: "#{sails.config.walletapi.host}/service/wallet/convert_ruby_to_star"
  addStarUrl: "#{sails.config.walletapi.host}/service/wallet/add_star"

getSessionKey = (done)=>
  walletSession = webCache.get('walletSession')
  if walletSession && walletSession['session_key'] && walletSession['expired_time'] && walletSession['expired_time'] > (new Date())
    return done(null, walletSession['session_key'])

  url = WALLET_API_URLS.sessionUrl
  request
    method: 'POST'
    uri: url
    form: {api_key: sails.config.walletapi.api_key}
  , (err, res, body)->
    if err
      sails.log.error("[WALLETAPI] getSessionKey: could not connect to #{url} #{JSON.stringify(err)}")
      return done(err, null)

    sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
    try
      robj = JSON.parse(body)    
    catch
      return done("API response is not JSON", null)
    if robj.status.toString() != '1000'
      sails.log.error("[WALLETAPI] getSessionKey: could not connect to #{url}: #{JSON.stringify(robj)} ")
      return done(robj.message, null)
    webCache.set('walletSession', robj.result)
    done(null, robj.result.session_key)

# params:
#   token
#   ruby money
#   project
#   note
exports.pickRuby = (params, done)=>
  getSessionKey (e, session_key)->
    if e
      webCache.del('walletSession')
      return done(err1, null)

    url = WALLET_API_URLS.pickRubyUrl
    form =
      token: params.token
      ruby: params.ruby
      project: params.project
      itemid: params.itemid
      note: params.note
      session_key: session_key

    request
      method: 'POST'
      uri: url
      form: form
    , (err, res, body)->
      if err
        sails.log.error("[WALLETAPI] pickRuby: could not connect to #{url} #{JSON.stringify(err)} #{JSON.stringify(body)}")
        return done(err, null)
        
      sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)      
      catch
        return done("API response is not JSON", null)
      if robj.status.toString()  != '1000'
        return done(robj.message, null)

      done(null, robj.result)


# params:
#   token
#   star money
#   project
#   note
exports.pickStar = (params, done)=>
  getSessionKey (err, session_key)->
    if err
      webCache.del('walletSession')
      return done({code: 5006, error: 'Could not process', log: "[WalletService.pickStar] ERROR: could not process... #{err}"})

    url = WALLET_API_URLS.pickStarUrl
    form =
      token: params.token
      star: params.star
      project: params.project
      itemid: params.itemid
      note: params.note
      session_key: session_key

    request
      method: 'POST'
      uri: url
      form: form
    , (err, res, body)->
      if err
        return done({code: 5010, error: 'Could not process', log: "[WalletService.pickStar] ERROR: could not process... #{err}"})
        
      sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)
      catch
        return done({code: 5011, error: "API response is not JSON", log: "[WalletService.pickStar] ERROR: could not JSON parse... #{err}"})
      if robj.status.toString() != '1000'
        return done({code: 5027, error: robj.message, log: "[WalletService.pickStar] ERROR: could not process... #{robj.message}"})

      done(null, robj.result)


# params:
# token
exports.viewMoney = (token, done)=>
  getSessionKey (e, session_key)->
    if e
      webCache.del('walletSession')
      return done(e, null)

    url = WALLET_API_URLS.viewMoneyUrl
    request
      method: 'POST'
      uri: url
      form:
        token: token
        session_key: session_key
    , (err, res, body)->
      if err
        sails.log.error("[WALLETAPI] viewMoney: could not connect to #{url} #{JSON.stringify(err)} #{JSON.stringify(body)}")
        return done(err, null)
        
      sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)      
      catch
        return done("API response is not JSON", null)
      if robj.status.toString()  != '1000'
        return done(robj.message, null)

      done(null, robj.result)


# params:
#   token
#   ruby money
#   project
#   note
exports.changeRubyToStar = (params, done)=>
  getSessionKey (e, session_key)->
    if e
      webCache.del('walletSession')
      return done({code: 5006, error: err1}, null)

    url = WALLET_API_URLS.changeRubyToStarUrl
    form =
      token: params.token
      ruby: params.ruby
      project: params.project
      note: params.note
      session_key: session_key

    request
      method: 'POST'
      uri: url
      form: form
    , (err, res, body)->
      if err
        sails.log.error("[WALLETAPI] changeRubyToStar: could not connect to #{url} #{JSON.stringify(err)} #{JSON.stringify(body)}")
        return done({code: 5010, error: err}, null)
        
      sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)      
      catch
        return done({code: 5011, error: "API response is not JSON"}, null)
      if robj.status.toString()  != '1000'
        return done({code: 5019, error: robj.message}, null)

      done(null, robj.result)

# params:
#   token
#   ruby money
#   project
#   note
exports.addStar = (params, done)=>
  getSessionKey (err, session_key)->
    if err
      webCache.del('walletSession')
      return done({code: 5006, error: err}, null)

    url = WALLET_API_URLS.addStarUrl
    form =
      token: params.token
      star: params.star
      project: params.project
      note: params.note
      session_key: session_key
    
    sails.log.info url
    sails.log.info form

    request
      method: 'POST'
      uri: url
      form: form
    , (err, res, body)->
      if err
        sails.log.error("[WALLETAPI] addStar: could not connect to #{url} #{JSON.stringify(err)} #{JSON.stringify(body)}")
        return done({code: 5010, error: err}, null)

      sails.log.info("[WALLETAPI]: #{url} with response: #{JSON.stringify(body)}")
      try
        robj = JSON.parse(body)      
      catch
        return done({code: 5011, error: "API response is not JSON"}, null)
      if robj.status.toString()  != '1000'
        return done({code: 5077, error: robj.message}, null)

      done(null, robj.result)

