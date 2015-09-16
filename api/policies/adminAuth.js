/**
 * sessionAuth
 *
 * @module      :: Policy
 * @description :: Simple policy to allow any authenticated user
 *                 Assumes that your login action in one of your controllers sets `req.session.authenticated = true;`
 * @docs        :: http://sailsjs.org/#!documentation/policies
 *
 */
module.exports = function(req, res, next) {
  sails.log.info('REQUEST: ' + req.route.path + 
                 '\n## HEADER - ' + JSON.stringify(req.headers) + 
                 '\n## BODY - ' + JSON.stringify(req.body));

  res.header('Access-Control-Allow-Credentials', true);
  
  if (req.session.adminID) {
    req.session.touch();
   	AdminUser.findOne({id:req.session.adminID})
    .populate('role')
    .exec(function(err, adminuser){
      if (err) {
          console.log({code:5000, error: err});
          return res.badRequest({code:5000, error: err});
      }
      if (adminuser) {
        if (!adminuser.isActive){
          return res.forbidden({code: 5124, err: 'Your Admin is not active.'});
        }
        Admin_AuthService.isPermitted(req, adminuser, function(err, ok){
          if (err) {
            console.log(err);
            return res.badRequest(err);
          }
          if (ok) {
            return next();
          }
          return res.forbidden({code: 5121, err: 'Your Role is not permitted to perform this action.'});
        })
      }
      else {
        return res.forbidden({code: 5122, err: 'Your Admin has been deleted.'});
      }
    });
	}
	else return res.forbidden({code: 5123, err: 'You have not loged in Admin.'});
};
