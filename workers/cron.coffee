CronJob = require('cron').CronJob
UserJob = require('./UserJob')
MathRoomJob = require('./MathRoomJob')
SocketJob = require('./SocketJob')
NoteMessageJob = require('./NoteMessageJob')
ChallengeJob = require('./ChallengeJob')
ItemJob = require('./ItemJob')

cronEveryMinute = ()=>
  sails.log.info 'starting cronEveryMinute......'
  job = new CronJob
    cronTime: '00 * * * * *'
    onTick: ()->

    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEvery15Minutes = ()=>
  job = new CronJob
    cronTime: '00 */15 * * * *'
    onTick: ()->
      sails.log.info 'run every 15 mins'
      MathRoomJob.detectRemoveDisableRooms()
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEveryHour = ()=>
  job = new CronJob
    cronTime: '00 00 * * * *'
    onTick: ()->
      sails.log.info 'run every hour'
      NoteMessageJob.detectRemoveExpiredNoteMessages()
      ChallengeJob.detectRemoveExpiredChallenge()
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEveryDay = ()=>
  job = new CronJob
    cronTime: '01 00 00 * * *'
    onTick: ()->
      sails.log.info 'run every day'
      UserJob.resetEnergy()
      ItemJob.resetGivenCount()
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

exports.start = (done)=>
  cronEveryMinute()
  cronEvery15Minutes()
  cronEveryHour()
  cronEveryDay()
  done(null)