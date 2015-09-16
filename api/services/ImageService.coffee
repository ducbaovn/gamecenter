async = require('async')
_ = require('lodash')

exports.list = (params, done) ->
  params.version ||= 0

  cond = 
    version:
      '>': params.version
      
  Image.find cond
  .sort({version: 'desc'})
  .exec (err, images) ->
    if err
      return done({code: 5000, error: "could not get image list", log: "[ImageService.list] ERROR: could not get image list ... #{JSON.stringify(err)}"})

    if images.length == 0
      return done(null, null)

    return done(null, {version: images[0].version, images: images})
