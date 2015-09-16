_ = require('lodash')

exports.detectRemoveExpiredChallenge = () ->
  timeNow = new Date()  
  cond = 
    isHolding: false
    expiredAt:
      '<=': timeNow

  Challenge.destroy cond, (err, challenges) ->
    if challenges.length > 0
      sails.log.info "remove #{challenges.length} expired challenge"
      challengeIds = _.pluck(challenges, 'id')      
      MathChallenge.destroy challenge: challengeIds
