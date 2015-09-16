amqp = require('amqp')
async = require('async')
queue = require('./queue')

startTask = ()=>
  task = new queue.MessageRouter(queue, 'task')

startGCM = ()=>
  gcm = new queue.MessageRouter(queue, 'gcm', queueName: 'gcm')

startAPN = ()=>
  apn = new queue.MessageRouter(queue, 'apn', queueName: 'apn')

exports.start = (cb)=>
  startTask()
  startGCM()
  startAPN()
  cb()