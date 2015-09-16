exports.execute = (msg, headers, deliveryInfo, done) ->
  sails.log.info "NOTIFY: #{msg}----#{headers}"
  done(null, "unsubscribe success for #{msg}")
