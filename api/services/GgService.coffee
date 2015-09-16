google = require('googleapis')
plus = google.plus('v1')
OAuth2 = google.auth.OAuth2

exports.fetchGgUser = (access_token,done)=>
  oauth2Client = new OAuth2(
    sails.config.google.client_id,
    sails.config.google.client_secret,
    sails.config.google.redirect_url)

  oauth2Client.setCredentials({access_token: access_token, })
  plus.people.get {userId: 'me', auth: oauth2Client }, (err, res)->
    if err
      return done('access_token is not valid', null)
    return done(null,res)

