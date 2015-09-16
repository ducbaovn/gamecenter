_ = require('lodash')
async = require('async')  

# exports.setMatchExpired = (match)->
#   obj = match.toObject()
#   now = new Date()
#   MathMatch.findOne match.id, (e, me)->
#     if e
#       return false
#     if now > me.expiredAt && me.status == MathMatch.STATUSES.PLAYING
#       me.status = MathMatch.FAIL
#       me.save()
  
exports.result = (params, done)->
  ChallengeMatch.findOne {id: params.match, user: params.user.id}
  .exec (err, acceptance)->
    if err
      return done({code: 5000, error: 'Could not process', log: "[ChallengeMatchService.result] ERROR: Could not process - get ChallengeMatch... #{err}"})
    if !acceptance
      return done({code: 6066, error: 'Invalid params.match', log: "[ChallengeMatchService.result] ERROR: ChallengeMatch not found"})
    if acceptance.status == ChallengeMatch.STATUSES.PLAYING
      Challenge.findOne challenge: acceptance.challenge
      .populate('score')
      .populate('user')
      .exec (err, challenge)->
        if err
          return done({code: 5000, error: 'Could not process', log: "[ChallengeMatchService.result] ERROR: Could not process - get Challenge... #{err}"})
        if !challenge
          return done({code: 6066,error: 'Invalid params.match', log: "[ChallengeMatchService.result] ERROR: Challenge not found"})

        challenge.playsCount = (challenge.playsCount || 0) + 1
        acceptance.score = params.score
        acceptance.time = params.time
        
        if acceptance.time < challenge.score.time || acceptance.score > challenge.score.score
          acceptance.status = ChallengeMatch.STATUSES.WIN
          challenge.failuresCount = (challenge.failuresCount || 0) + 1
          acceptance.save()
          challenge.save (err, success)->
            if err
              return done({code: 5000, error: 'Could not process', log: "[ChallengeMatchService.result] ERROR: Could not process - update Challenge #{err}"})
            if LockerService.isLocked challenge.id
              LockerService.unlock challenge.id
          # return money for acceptance user
          pm =
            star: challenge.moneyPerOne * (2 - Challenge.FEE_PERCENT)
            itemid: challenge.id
            note: "Thắng thách thức #{challenge.id}"
            gameCode: challenge.gameCode
          MoneyService.incStars params.user, pm, (err, dn)->
            sails.log.info err.log

          return done(null, {result: ChallengeMatch.STATUSES.WIN})

        else
          acceptance.status = ChallengeMatch.STATUSES.FAIL
          acceptance.save()
          challenge.save (err, success)->
            if err
              return done({code: 5000, error: 'Could not process', log: "[ChallengeMatchService.result] ERROR: Could not process - update Challenge #{err}"})
            if LockerService.isLocked challenge.id
              LockerService.unlock challenge.id
          # return money for challenge user
          pm2 =
            star: challenge.moneyPerOne * (1 - Challenge.FEE_PERCENT)
            itemid: challenge.id
            note: "Thách thức #{challenge.id} không bị đánh bại"
            gameCode: challenge.gameCode
          MoneyService.incStars challenge.user, pm2, (err, dn)->
            sails.log.info err.log
        
          return done(null, {result: ChallengeMatch.STATUSES.FAIL})
    else
      return done(null, {result: acceptance.status})