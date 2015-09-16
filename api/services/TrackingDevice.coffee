exports.save = (req)=>
  user = req.user
  platform = req.headers['platform']
  deviceid = req.headers['deviceid']
  if !platform || !deviceid || !Device.PLATFORMS[platform]
    return false

  Device.findOne {deviceid: deviceid, platform: platform}, (e, device)->
    if e
      return false

    if ! device
      Device.create {deviceid: deviceid, platform: platform, user: user.id}, (e, d)->
        return true
      return true
    if device.user != user.id
      device.user = user.id
      device.save()
    return true
