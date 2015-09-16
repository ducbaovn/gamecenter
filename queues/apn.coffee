_ = require('lodash')
APN = require("apns")
ObjectId = require('mongodb').ObjectID

exports.execute = (msg, headers, deliveryInfo, done) ->
  userIds = msg.users
  message = msg.data
  if ! userIds?
    return done(null, "APN: not valid notify")

  users = []
  _.each userIds, (id)->
    users.push ObjectId(id)

  Device.native (e, collections)->
    if e
      return done(e, null)

    collections.find
      user: {$in: users}
      platform: Device.PLATFORMS.IOS
      enabled: true
    , 
      deviceid: true
    .toArray (e, devices)->
      if e
        return done(null, e)
      if devices.length == 0
        return done(null, 'no devices found')

      async.each devices, (device, cb)->
        connection = new APN.Connection(sails.config.apn);
     
        notification = new APN.Notification();        
        notification.device = new APN.Device(device.deviceid);  
        notification.badge = message.badge
        notification.sound = message.sound
        notification.alert = message.alert
        notification.payload = message.payload

        connection.sendNotification(notification);
        
        sails.log.info "> Send IOS push notication to devices: #{JSON.stringify(device)}"

        cb()
      , (e)->
        if e
          return done(null, e)
        done(null, "unsubscribe success for #{msg}")
