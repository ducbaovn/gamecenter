_ = require('lodash')

exports.list = (done) ->
  Configuration.find {}
  .sort({gamecode: 'asc'})
  .exec (err, configs) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[ConfigService.list] ERROR: #{JSON.stringify(err)}"})
    return done(null, configs)

exports.getConfig = (gamecode, done) ->
  cond =
    gamecode: gamecode
  Configuration.findOne cond, (err, configuration) ->
    if err
      return done({code: 6210, error: 'Cannot get configuration', log: "[ConfigService.getConfig] ERROR: #{JSON.stringify(err)}"})      
    if !configuration
      return done({code: 6210, error: 'Cannot find game configuration', log: "Cannot find game configuration"})      
    return done(null, configuration.config)

exports.getCommonConfig = (done) -> 
  exports.getConfig Game.VISIBLE_APIS.SMART_PLUS, done

exports.setConfig = (gamecode, value, done) ->
  if typeof value == 'string'
    try
      value = JSON.parse(value || '{}')
    catch
      return done({code: 6212, error: "JSON string is invalid"})

  Configuration.update {gamecode: gamecode}, {value: value}, (err, configs) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[ConfigService.setConfig] ERROR: #{JSON.stringify(err)}"})
    return done(null, configs)
