/**
 * Allow any authenticated user.
 */

module.exports = function (req, res, next) {
  sails.log.info('REQUEST: ' + req.route.path + 
                 '\n## HEADER - ' + JSON.stringify(req.headers) + 
                 '\n## BODY - ' + JSON.stringify(req.body));

  var token = req.headers['x-auth-token'];
  if (!token) {
    return res.badRequest({code: 5001, error: 'Bad Request'});
  }

  User.findOne({token: token}, function(err, user) {
    if (err) {
      return res.forbidden({code: 5000, error: err});
    }

    if (!user) {
      return res.forbidden({code: 5002, error: 'You are not permitted to perform this action.'});
    }

    var today = new Date();
    if (today > user.tokenExpireAt) {
      return res.forbidden({code: 5003, error: 'Token expired'});
    }

    req.user = user;
    TrackingDevice.save(req);

    return next();
  });
};