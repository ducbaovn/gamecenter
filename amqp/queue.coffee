amqp = require('amqp')
async = require('async')
fs = require('fs')

exports.exchangeMapping = {}

# This allows us to have user specific queues so that we don't step on
# each others toes. It uses process.env.USER to create a new queue that
# is named after each of us. This only happens in development, so not a
# big deal for production.
getQueueName = (name) ->
  "#{name}-#{process.env.NODE_ENV}_queue"

autoDeleteAMQP = () ->
  if process.env.NODE_ENV == 'development'
    true 
  else 
    false


#
# Sadly, this is a bit more complicated than it needs to be because we need to
# setup connections to multiple services in case of trouble publishing because
# a service is down. We don't care about the workers because once the message is
# in the queue, it is durable. This is written so that we can have an unlimited
# number of fallback services, although 2 is probably good enough.
#
# In the future, we may need to split out long running tasks into separate queues,
# but all of my experience has shown me that we should try to keep the tasks as
# short as possible. If it is a long task, it should be split into shorter tasks.
#
exports.start = (done) ->
  connectServer = (server, servercb) ->
    sails.log.info "Connecting to AMQP...."
    conn = amqp.createConnection(server)
    conn.on 'ready', ->
      sails.log.info "Connected to AMQP...."
      map = []
      # flatten things out to make it less of an async headache.
      for exchange in server.bindings
        for queue in exchange.queues
          map.push { exchange: exchange, queue: queue }

      buildMapping = (mapItem, cb) ->
        exchangeName = mapItem.exchange.name
        queueName = getQueueName(mapItem.queue.name)
        # In the future, we may want to specify the configuration for exchange/queue in the environment
        # configuration. For now, these defaults are ok though.
        conn.exchange exchangeName, {type: 'direct', confirm: true, durable: true}, (connExchange) ->
          conn.queue queueName, {autoDelete: autoDeleteAMQP(), durable: true}, (connQueue) ->
            sails.log.info "exchangeName: #{exchangeName}; queueName: #{queueName}"
            routing = "#{queueName}Routing"
            connQueue.bind(connExchange, routing)

            # build a mapping of exchange/queue objects across multiple servers, for later use
            key = exchangeName + queueName
            if ! exports.exchangeMapping[key]
              exports.exchangeMapping[key] = []

            exports.exchangeMapping[key].push
              exchange: connExchange
              queue: connQueue
              routing: routing
              queueName: queueName

            cb()
      async.forEach map, buildMapping, () ->
        sails.log.info exports.exchangeMapping
        sails.log.info "rabbit server: #{server.name}"
        servercb()

  # This is done in series because we have the concept of a primary server
  connectServer sails.config.amqp, () ->
    done(null, 'started')


# If we fail to send to one server, then we try another one.
exports.sendMessage = (msg, callback) ->
  return require("#{process.cwd()}/queues/#{msg.task}").execute(msg, null, null, callback)

  if ! msg.exchangeName
    nameEX = sails.config.amqp.bindings[0]?.name || 'scexchange'
    msg.exchangeName = nameEX
  if ! msg.queueName
    msg.queueName = 'task'
  msg.queueName = getQueueName(msg.queueName)
  exports.sendMessageDestination(msg.exchangeName, msg.queueName, msg, callback)

exports.sendMessageDestination = (exchangeName, queueName, msg, callback) ->
  exchangeData = exports.exchangeMapping[exchangeName + queueName]

  if exchangeData
    exec = (obj, cb) ->
      obj.exchange.publish "#{queueName}Routing", msg, {deliveryMode: 2}, (error) ->
        if error
          sails.log.info "queueFailure: #{JSON.stringify(error)}"
          cb(false)
        else
          cb(true)

    async.some exchangeData, exec, (result) ->
      sails.log.info result
      if callback
        if result
          callback(null, 'success publishing to queue:' + queueName)
        else
          callback('error publishing to queue:' + queueName)
  else
    msg = "!!!!!!!!!!!!!!!!!!!!!!!!!!! failed to find exchangeData for mapping: e: #{exchangeName} q: #{queueName} - most likely a environment configuration issue."
    sails.log.info msg
    if callback
      callback(msg)

# Subscribe to a specific queue and execute callback when a message is received.
exports.subscribe = (queueObj, callback) ->
  queueObj.subscribe { ack: true, prefetchCount: 1 }, (msg, headers, deliveryInfo) ->
    sails.log.info "subscribe queueObj: #{queueObj}"
    callback(msg, headers, deliveryInfo)

# This handles subscribing to a queue (based on the route that is passed into the constructor)
# It will subscribe to all of the configured queues across all of the servers. It will then
# route messages to the tasks in the task directory based on what messages come in.
exports.MessageRouter = class MessageRouter
  constructor: (@queueService, routingKey) ->
    routingKey = getQueueName(routingKey)

    # Init our tasks and add the execute method to the list.
    @tasks = {}
    fs.readdir "#{process.cwd()}/queues", (err, files) =>
      for file in files
        action = file.split('.')
        @tasks[action[0]] = require("#{process.cwd()}/queues/#{action[0]}").execute

      # Subscribe to all of the available 'tasks' queues and setup routing so that
      # when a message comes in, we can send it to the appropriate task to execute it
      sails.log.info @queueService
      for key, mapping of @queueService.exchangeMapping
        sails.log.info "key: #{key}; mapping: #{mapping}"
        for map in mapping
          sails.log.info "map: #{map}; #{map.queueName}; #{routingKey}"
          if map.queueName == routingKey
            do (map) =>
              sails.log.info "subscribed to queue: #{map.queueName}"
              @queueService.subscribe map.queue, (msg, headers, deliveryInfo) =>
                @routeMessage(map.queue, msg, headers, deliveryInfo)

  # Pairs up the message with the right task and executes it.
  routeMessage: (v, msg, headers, deliveryInfo) =>
    if msg.task && @tasks[msg.task]
      # All tasks should execute this done message if things complete ok.
      done = (err, msg) ->
        if err
          # crash the dyno so that another instance can try again.
          # throw "error processing message: #{JSON.stringify(msg)}, error: #{JSON.stringify(err)}"
        else
          if msg then sails.log.info msg
          v.shift()
      # Lookup the cached task function and execute it
      sails.log.info @tasks[msg.task]
      @tasks[msg.task](msg, headers, deliveryInfo, done)
    else
      sails.log.info("Unknown task (#{msg.task}). Message: #{JSON.stringify(msg)}")

