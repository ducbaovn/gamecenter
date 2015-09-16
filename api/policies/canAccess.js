module.exports = function (req, res, next) {
  sails.log.info('REQUEST: ' + req.route.path + 
                 '\n## HEADER - ' + JSON.stringify(req.headers) + 
                 '\n## BODY - ' + JSON.stringify(req.body));

  if (req.headers['x-nahi-token'] == sails.config.mobile.api_key) {
    return next();
  }
  return res.badRequest({code: 5001, error: 'Bad Request'});
}