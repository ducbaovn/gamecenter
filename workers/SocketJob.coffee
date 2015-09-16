_ = require('lodash')

exports.detectExpiredSockets = ()->
  dateNow = new Date()
  sails.log.info "detectExpiredSockets.........."
  UserSocket.destroy {expiredAt: {'<': dateNow}}, (e, r)->
    sails.log.info "destroy UserSocket: #{JSON.stringify(r)}"

