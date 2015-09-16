module.exports = 

  login: (req, res) ->
    res.header("Access-Control-Allow-Credentials", true)

    Admin_AuthService.login
      email: req.param('email')
      password: req.param('password')
    , (err, user) ->      
      if err
        res.badRequest(err)
      else 
        req.session.adminID = user.id
        res.status(200).send(user)
  
  logout: (req, res) ->
    res.header("Access-Control-Allow-Credentials", true)
    req.session.destroy (err)->
      if err
        res.badRequest(err)
      else
        res.status(200).send({success: 'Log out success'})