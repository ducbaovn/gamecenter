exports.execute = (msg, headers, deliveryInfo, done) ->
  sails.log.info msg
  sails.log.info headers
  sails.log.info "msg----headers"
  done(null, "unsubscribe success for #{msg}")