module.exports = function (req, res, next) {
  if (!req.isSocket) {
    return res.badRequest({code: 5001, error: 'Bad Request'});
  }

  sails.log.info('SOCKET REQUEST: ' + req.route.path + 
                 '\n## HEADER - ' + JSON.stringify(req.headers) + 
                 '\n## BODY - ' + JSON.stringify(req.body));

  var token = req.headers['x-auth-token'];  
  if (!token) {
    token = req.param('token');    
  }  
  
  var socketId = sails.sockets.id(req.socket);
  if (!token) {
    sails.sockets.emit(socketId, 'SOCKET_ERROR', {code: 5001, error: 'Bad Request'});
    sails.log.warn('Sending 400 ("Bad Request") socket response:\n', {code: 5001, error: 'Bad Request'});
    return res.badRequest({code: 5001, error: 'Bad Request'});
  }

  User.findOne({token: token}, function(err, user) {
    if (err) {
      sails.sockets.emit(socketId, 'SOCKET_ERROR', {code: 5000, error: err});
      sails.log.info('Sending 403 ("Forbidden") socket response: \n', {code: 5000, error: err});
      return res.forbidden({code: 5000, error: err});
    }
    
    if (!user) {
      sails.sockets.emit(socketId, 'SOCKET_ERROR', {code: 5002, error: "You are not permitted to perform this action."});
      sails.log.info('Sending 403 ("Forbidden") socket response: \n', {code: 5002, error: "You are not permitted to perform this action."});
      return res.forbidden({code: 5002, error: 'You are not permitted to perform this action.'});
    }

    var today = new Date();
    if (today > user.tokenExpireAt) {      
      sails.sockets.emit(socketId, 'SOCKET_ERROR', {code: 5003, error: "Token expired"});
      sails.log.info('Sending 403 ("Forbidden") socket response: \n', {code: 5003, error: "Token expired"});
      return res.forbidden({code: 5003, error: 'Token expired'})
    }

    req.user = user;
    SocketService.bindingSocket(req);
    
    return next();
  });
};