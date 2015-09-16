APN = require('apns')
Queue = require(process.cwd()+'/amqp/queue')
  
exports.pushNote = (note, cb)=>

  message =
    expiry: note.expiredAt
    sound: note.sound
    badge: note.badge
    alert: note.title
    payload:
      id: note.id
      title: note.title
      category: note.category
      userId: note.user.id

  Queue.sendMessage
    task: 'apn'
    queueName: 'apn'
    data: message
    users: [note.user.id || note.user]
  , cb