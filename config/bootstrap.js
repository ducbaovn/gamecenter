/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 * 
 * It's very important to trigger this callback method when you are finished
 * with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap) 
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html
 */

var async = require('async');
var _ = require('lodash');
var path = require('path');
var SeedData = require(process.cwd()+'/data/seed');
var Cron = require(process.cwd()+'/workers/cron');
var AmqpServer = require(process.cwd()+'/amqp/server');
var QueueServer = require(process.cwd()+'/amqp/queue');
var MathRoomJob = require(process.cwd()+'/workers/MathRoomJob');

module.exports.bootstrap = function(cb) {

  // override sails.log.eror to print stacktrace
  var _oldSailsLogError = sails.log.error;
  sails.log.error = function (msg) {
    if (typeof msg == 'string') {
      msg = new Error(msg);
    }

    _oldSailsLogError(msg);
  }; 

  // math room bootstrap
  MathRoomJob.clearAllRooms();

  // data bootstrap
  async.parallel([
    SeedData.import,
    Cron.start,
    RedisService.init,
    // QueueServer.start
  ], function () {
    // AmqpServer.start(cb);

    // bootstrap images version
    RedisService.exists(Image.IMAGE_VERSION_KEY, function (exists) {
      if (!exists) {
        RedisService.set(Image.IMAGE_VERSION_KEY, 0);
      }
    });
  });

  // catch connected socket
  sails.io.on('connect', function (socket){
    var socketId = sails.sockets.id(socket);
    console.log('.......................... connect: ' + socketId);     
  });

  cb();
};
