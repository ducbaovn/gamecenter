redis = require('redis')
connection = sails.config.redis
client = null

module.exports = 
  init: (done) ->
    client = redis.createClient(connection.port, connection.host)

    if connection.password
      client.auth connection.password, (err) ->
        if err
          return done(false)        

    client.on 'connect', () ->         
      client.select connection.database || 0, (err) ->
        if err
          return done(false)
        sails.log.info "Connected Redis [#{connection.database}] ...."
        return done(null)

    client.on 'error', () ->
      return done(false)

  get: (key, done) ->
    if !client
      return done('No Redis client')
    
    done = done || ()->
    client.get key, (err, value)->
      if err
        sails.log.info err
        return done(err)
      return done(null, value)

  set: (key, value, ttl, done) ->
    if !client
      return done('No Redis client')

    done = done || ()->  
    client.set key, value, (err)->      
      if err
        sails.log.info err
        return done(err)
      if ttl
        client.expire key, ttl
      return done(null)

  del: (key, done) ->
    if !client
      return done('No Redis client')
    
    done = done || ()->
    client.del key, (err)->
      if err
        sails.log.info err
        return done(err)
      return done(null)

  incr: (key, done) ->
    if !client
      return done('No Redis client')
    
    done = done || ()->
    client.incr key, (err, value)->
      if err
        sails.log.info err
        return done(err)
      return done(null, value)

  exists: (key, done) ->
    if !client
      return done(false)
      
    done = done || ()->
    client.exists key, (err, reply) ->
      if err
        sails.log.info err
        return done(false)
      return done(reply == 1)