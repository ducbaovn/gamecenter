_ = require('lodash')
GCM = require('node-gcm')
ObjectId = require('mongodb').ObjectID

exports.execute = (msg, headers, deliveryInfo, done) =>
  userIds = msg.users
  message = msg.data
  if ! userIds?
    return done(null, "GCM: not valid notify")

  users = []
  _.each userIds, (id)->
    users.push ObjectId(id)

  Device.native (e, collections)->
    if e
      return done(e, null)

    collections.find
      user: {$in: users}
      platform: Device.PLATFORMS.ANDROID
      enabled: true
    , 
      deviceid: true
    .toArray (e, devices)->
      if e
        return done(null, e)
      if devices.length == 0
        return done(null, 'no devices found')

      devices = _.pluck(devices, 'deviceid')

      gcmSender = new GCM.Sender(sails.config.gcm.apiKey)      
      gcmSender.send message, devices, 4, (e, rt)->
        if e
          return done(null, e)
        sails.log.info "> Send Android push notication to devices: #{JSON.stringify(devices)}"        
        done(null, "unsubscribe success for #{msg}")


loggingNote = (msg, devices)=>
  data =
    targets: msg.users
    note: msg.data
    timestamp: (new Date())
    attempts: 1
    devices: devices
    platform: Device.PLATFORMS.ANDROID