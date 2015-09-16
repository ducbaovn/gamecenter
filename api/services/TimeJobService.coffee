require('date-utils')
CronJob = require('cron').CronJob

exports.queue = (datetime, func)->
  job = new CronJob datetime, ()->
    func()
  , ()->
    sails.log.info 'TimeJobService run finished'
  , true
  # ,timeZone: "Asia/Saigon"  
