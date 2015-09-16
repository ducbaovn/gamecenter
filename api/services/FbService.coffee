https = require('https')

get = (access_token, apiPath, params='', cb) ->
  options =
    host: 'graph.facebook.com'
    port: 443
    path: apiPath + '?access_token=' + access_token + '&' + params
    method: 'GET'

  buffer = ''

  request = https.request options, (result) ->
    result.setEncoding('utf8')
    result.on 'data', (chunk) ->
      buffer += chunk
    result.on 'end', () ->
      cb(buffer)

  request.on 'error', (e) ->
    sails.log.info('error from facebook.get(): ' + e.message)

  request.end()

exports.fetchFbUser = (access_token, done)=>
  get access_token, '/me', 'fields=id,first_name,last_name,name,gender,email,birthday,location,link,picture,timezone,updated_time,verified', (data) ->
    try
      data = JSON.parse(data)
      if data.error
        return done(data.error, null)
      return done(null, data)
    catch
      return done('API response is not JSON', null)
