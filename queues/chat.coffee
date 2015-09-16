exports.execute = (msg, headers, deliveryInfo, done) ->
  sails.log.info "CHAT: #{msg}----#{headers}"
  done(null, "unsubscribe success for #{msg}")