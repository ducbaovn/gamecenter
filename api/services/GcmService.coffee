GCM = require('node-gcm')
Queue = require(process.cwd()+'/amqp/queue')
  
exports.pushNote = (note, cb, delayWhileIdle=true, timeToLive=3)=>

  messageData = 
    collapseKey: note.sound
    delayWhileIdle: delayWhileIdle
    timeToLive: timeToLive
    data:
      id: note.id
      title: note.title
      category: note.category
      userId: note.user.id

  if note.extends
    messageData.data = _.merge(messageData.data, note.extends)

  message = new GCM.Message(messageData)
  
  Queue.sendMessage
    task: 'gcm'
    queueName: 'gcm'
    data: message
    users: [note.user.id || note.user]
  , cb