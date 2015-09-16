/**
 * Built-in Log Configuration
 * (sails.config.log)
 *
 * Configure the log level for your app, as well as the transport
 * (Underneath the covers, Sails uses Winston for logging, which
 * allows for some pretty neat custom transports/adapters for log messages)
 *
 * For more information on the Sails logger, check out:
 * http://sailsjs.org/#/documentation/concepts/Logging
 */

require('date-utils');
var winston = require('winston');
var nodemailer = require('nodemailer');
var smtpTransport = require('nodemailer-smtp-transport');

/********************************************
 * Log configurations                       *
 ********************************************/
var LOG_CONFIG = {
  logfile: 'logs/error.log',
  debug: true,
  sendmail: true,
  smtp: {
    host: 'smtpcorp.com',
    port: 2525,
    username: 'whatthemailtest@gmail.com',
    password: 'nguyenlinhduy',
    from: 'NAHI GAMECENTER ERROR <whatthemailtest@gmail.com>',
    to: 'popbiboy@gmail.com'
  }
};

/********************************************
 * Send error log mail                      *
 ********************************************/
function sendErrorLogMail(subject, content) {
  var transporter = nodemailer.createTransport(smtpTransport({
    host: LOG_CONFIG.smtp.host,
    port: LOG_CONFIG.smtp.port,
    auth: {
      user: LOG_CONFIG.smtp.username,
      pass: LOG_CONFIG.smtp.password
    }
  }));
  
  transporter.sendMail({
    from: LOG_CONFIG.smtp.from,
    to: LOG_CONFIG.smtp.to,
    subject: subject,
    text: content
  });
};

/********************************************
 * Create logger transport                  *
 ********************************************/
var fileLogger = {
  level: 'error',
  filename: LOG_CONFIG.logfile,
  json: false,
  maxsize: 1048576, // in byte
  timestamp: function() {
    return new Date();
  },
  formatter: function(options) {
    var now = options.timestamp();      
    var message = options.message.replace('[31m', '').replace('[39m', '');
    
    var logMessage = '[' + now.toFormat('YYYY-MM-DD HH24:MI:SS.') + ('000' + now.getMilliseconds()).slice(-3) + ' ' + now.getUTCOffset() + '] ' +
                    '[' + options.level.toUpperCase() + '] ' + (message || '') +
                    '\n\n=============================================================================';

    if (LOG_CONFIG.sendmail) {
      var endOfLineIndex = message.indexOf('\n');
      var title = "****** [GC ERROR] " + (endOfLineIndex != -1 ? message.substring(0, endOfLineIndex) : '');
                      
      sendErrorLogMail(title, logMessage);
    }

    return logMessage;
  }
};

var consoleLogger = {
  level: 'debug',
  json: false,
  timestamp: function() {
    return new Date();
  },
  formatter: function(options) {    
    var now = options.timestamp();
    return '[' + now.toFormat('YYYY-MM-DD HH24:MI:SS.') + ('000' + now.getMilliseconds()).slice(-3) + ' ' + now.getUTCOffset() + '] ' +
           '[' + options.level.toUpperCase() + '] ' + (options.message || '')
  }
};

/********************************************
 * Custom logger                            *
 ********************************************/
var loggerTransport = [];
loggerTransport.push(new winston.transports.File(fileLogger));

if (LOG_CONFIG.debug) {
  loggerTransport.push(new winston.transports.Console(consoleLogger));
}

var customLogger = new winston.Logger({
   transports: loggerTransport
});


module.exports.log = {

  /***************************************************************************
  *                                                                          *
  * Valid `level` configs: i.e. the minimum log level to capture with        *
  * sails.log.*()                                                            *
  *                                                                          *
  * The order of precedence for log levels from lowest to highest is:        *
  * silly, verbose, info, debug, warn, error                                 *
  *                                                                          *
  * You may also set the level to "silent" to suppress all logs.             *
  *                                                                          *
  ***************************************************************************/
  
  custom: customLogger

};
