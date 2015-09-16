_ = require('lodash')
async = require('async')


exports.lockChallenge = (challenge)=>
  obj = challenge.toObject()
  Challenge.update {id: obj.id}, {isHolding: true}, (e, rst)->
    if e
      sails.log.info "could not lock challenge #{obj.id}"
    sails.log.info "lock: #{JSON.stringify(challenge.id)}"

exports.unlockChallenge = (challenge)=>
  obj = challenge.toObject()
  Challenge.update {id: obj.id}, {isHolding: false}, (e, rst)->
    if e
      sails.log.info "could not unlock challenge #{obj.id}"

    sails.log.info "unlock: #{JSON.stringify(challenge.id)}"
    return true  

exports.setMatchExpired = (match)=>
  obj = match.toObject()
  now = new Date()
  MathMatch.findOne match.id, (e, me)->
    if e
      return false
    if now > me.expiredAt && me.status == MathMatch.STATUSES.PLAYING
      me.status = MathMatch.FAIL
      me.save()
  

exports.postMatchScore = (req, done)=>
  params =
    time: req.param('time')
    match: req.param('matchid')

  MathMatch.findOne {id: params.match, user: req.user.id}
  .populate('mathchallenge')
  .populate('user')  
  .exec (err, acceptance)->
    if err
      return done({code: 5000, error: err}, null)
    if !acceptance
      return done({code: 5043, error: 'not found match'}, null)

    challenge = acceptance.mathchallenge

    MathChallenge.findOne {challenge: challenge.id}, (e, mathchallenge)->
      if e
        return done({code: 5000, error: e}, null)
      if !mathchallenge
        return done({code: 5040,error: 'not found match challenge'}, null)

      challenge.playsCount += 1
      if params.time > mathchallenge.time
        acceptance.timeScore = params.time
        acceptance.status = MathMatch.STATUSES.FAIL
        acceptance.mathchallenge = acceptance.mathchallenge.id
        acceptance.user = acceptance.user.id

        challenge.isHolding = false

        acceptance.save()
        challenge.save()

        # inc money for challenge creator
        User.findOne {id: challenge.user}, (e, challengeuser)->    
          if !e || challengeuser    
            pm =
              star: challenge.moneyPerOne
              itemid: challenge.id
              note: "Thách thức không bị đánh bại"
              gameCode: challenge.gameCode
            MoneyService.incStars challengeuser, pm, (e, dn)->
              sails.log.info e

        return done(null, MathMatch.STATUSES.FAIL)

      acceptance.timeScore = mathchallenge.time
      acceptance.status = MathMatch.STATUSES.WIN
      acceptance.mathchallenge = acceptance.mathchallenge.id
      acceptance.user = acceptance.user.id

      challenge.isHolding = false
      challenge.failuresCount = (challenge.failuresCount || 0) + 1

      acceptance.save()
      challenge.save()

      # inc money for challenge accepter
      User.findOne {id: acceptance.user}, (e, acceptanceuser)->    
        if !e || acceptanceuser 
          pm2 =
            star: challenge.moneyPerOne * 2
            itemid: challenge.id
            note: "Thắng thách thức"
            gameCode: challenge.gameCode
          MoneyService.incStars acceptanceuser, pm2, (e, dn)->
            sails.log.info e
        
      return done(null, MathMatch.STATUSES.WIN)