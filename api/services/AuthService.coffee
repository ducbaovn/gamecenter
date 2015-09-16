authCache = require('lru-cache')

exports.loginFb = (req, resp, done)=>
  if !req.param('access_token')
    resp.status(400).send(code: 5008, error: 'missing access_token')
    return

  WebService.fbLogin
    access_token: req.param('access_token')
    deviceid: req.param('deviceid')
    package: req.param('package')
    timeout: req.param('timeout')
  , (err, user)=>
    if err
      resp.status(400).send(err)
      return
    resp.status(200).send(user)

exports.loginGg = (req, resp, done)=>
  if !req.param('access_token')
    resp.status(400).send(code: 5008, error: 'missing access_token')
    return

  WebService.ggLogin
    access_token: req.param('access_token')
    deviceid: req.param('deviceid')
    package: req.param('package')
    timeout: req.param('timeout')
  , (err, user)=>
    if err
      resp.status(400).send(err)
      return
    resp.status(200).send(user)

exports.loginDb = (req, resp, done)=>
  WebService.login
    email: req.param('email')
    password: req.param('password')
    deviceid: req.param('deviceid')
    package: req.param('package')
    timeout: req.param('timeout')
  , (err, user)=>
    if err
      resp.status(400).send(err)
      return
    resp.status(200).send(user)

exports.register = (req, resp, done)=>
  WebService.register
    email: req.param('email')
    password: req.param('password')
    nickname: req.param('nickname')
    fullname: req.param('fullname')
    cellphone: req.param('cellphone')
    dob: req.param('dob')
    gender: req.param('gender')
    timeout: req.param('timeout')
    package: req.param('package')
  , (err, user)->
    if err
      resp.status(400).send(err)
      return
    resp.status(200).send(user)

exports.registerFb = (req, resp, done)=>
  WebService.fbRegister
    access_token: req.param('access_token')
    email: req.param('email')
    password: req.param('password')
    dob: req.param('dob')
    cellphone: req.param('cellphone')
    fullname: req.param('fullname')
    gender: req.param('gender')
    timeout: req.param('timeout')
    package: req.param('package')
  , (err, user)->
    if err
      resp.status(400).send(err)
      return
    resp.status(200).send(user)

exports.registerGg = (req, resp, done)=>
  WebService.ggRegister
    access_token: req.param('access_token')
    email: req.param('email')
    password: req.param('password')
    dob: req.param('dob')
    cellphone: req.param('cellphone')
    fullname: req.param('fullname')
    gender: req.param('gender')
    timeout: req.param('timeout')
    package: req.param('package')
  , (err, user)->
    if err
      resp.status(400).send(error: err)
      return
    resp.status(200).send(user)

exports.logout = (req, resp)=>
  user = req.user
  token = req.headers['x-auth-token'] || req.param('token')
  WebService.logout token, (err, rt)=>
    if err
      return resp.status(400).send(err)
    if user?
      user.token = null
      user.webToken = null
      user.socketId = null
      user.save()
      req.user = null
    resp.status(200).send({message: 'OK'})
  