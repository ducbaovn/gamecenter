
module.exports =
  
  loginDb: (req, resp)->
    AuthService.loginDb req, resp, (err, user)=>
      if err
        sails.log.info err
        return

  loginFb: (req, resp)->
    AuthService.loginFb req, resp, (err,user)=>
      if err
        sails.log.info err
        return

  loginGg: (req, resp)->
    AuthService.loginGg req, resp, (err,user)=>
      if err
        sails.log.info err
        return

  logOut: (req, resp, done)->
    AuthService.logout req, resp

  register: (req, resp)->
    AuthService.register req, resp, (err, user)=>
      if err
        sails.log.info err
        return

  registerFb: (req, resp)->
    AuthService.registerFb req, resp, (err, user)=>
      if err
        sails.log.info err
        return

  registerGg: (req, resp)->
    AuthService.registerGg req, resp, (err, user)=>
      if err
        sails.log.info err
        return
