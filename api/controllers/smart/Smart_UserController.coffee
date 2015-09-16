 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://links.sailsjs.org/docs/controllers
_ = require('lodash')

module.exports =
  me: (req, resp, done)->
    resp.status(200).send(UserService.myAttrs(req.user))

  getProfile: (req, resp, done)->
    UserService.getProfile req.param('id'), (err, user)->
      if err
        resp.status(400).send(err)
        return
      resp.status(200).send(user)
  
  rubyToStars: (req, resp)->
    user = req.user
    params = 
      ruby: req.param('ruby')
      project: user.package
      note: "Đổi tiền kim cương qua smartcenter"
    MoneyService.rubyToStars user, params, (e, money)->
      if e
        return resp.status(400).send(e)

      return resp.send(success: 'ok')

  search: (req, resp)->
    query = req.param('query')
    cond =
      id: 
        '!': req.user.id
      $or: [
        email:
          contains: query
      ,
        nickname:
          contains: query        
      ]
    User.find cond, (e, users)->
      if e
        resp.status(400).send({code: 5000, error: e})
      userJSON = []
      _.each users, (user)->
        userJSON.push(user.publicJSON())

      resp.send(userJSON)

      
  updateAvatar: (req, resp)->
    params =
      token: req.headers['x-auth-token'] || req.param('token')
      avatar: req.param('avatar')
      filename: req.param('filename')
    
    UserService.updateAvatar params, (e, user)->
      if e
        return resp.badRequest(e)      
      return resp.ok(avatar_url: user.avatar_url)

      
  updateNickName: (req,resp)->
    params = 
      user: req.user
      nickname: req.param('nickname')
      
    UserService.updateNickName params, (e,done)->
      if e
        return resp.status(400).send(e)
      return resp.send(success: 'ok')
