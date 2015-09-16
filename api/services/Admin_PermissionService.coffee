exports.list = (done) ->
  Permission.find {}
  .sort({ordering: 'asc'})
  .exec (err, ps)->
    if err
      return done({code: 5000, error: err}, null)
    return done(null, ps)