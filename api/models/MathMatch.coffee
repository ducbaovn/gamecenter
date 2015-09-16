# MathMatch.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/#!documentation/models

# store acceptance of math challenge
CHALLENGE_STATUS = ['PLAYING', 'WIN', 'FAIL']
EXPIRED_IN_SECONDS = 30
module.exports =
  STATUSES: 
    PLAYING: CHALLENGE_STATUS[0]
    WIN: CHALLENGE_STATUS[1]
    FAIL: CHALLENGE_STATUS[2]
  EXPIRED_IN_SECONDS: EXPIRED_IN_SECONDS
  attributes:
    user:
      model: 'user'
      required: true

    mathchallenge:
      model: 'challenge'
      required: true

    status:
      type: 'string'
      enum: CHALLENGE_STATUS
      defaultsTo: CHALLENGE_STATUS[0]

    timeScore:
      type: 'integer'

    expiredAt:
      type: 'datetime'
      required: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.user
      delete obj.status
      obj
    
  afterCreate: (values, next)->
    # MathChallenge.findOne values.mathchallenge, (e, challenge)->
    #   if e
    #     sails.log.info 'could not holding challenge'
    #     return
    #   if ! challenge
    #     sails.log.info 'not found challenge'
    #     return
    #   challenge.isHolding = true
    #   challenge.save()
    #   setTimeout () ->
    #     challenge.isHolding = false
    #     challenge.save()
    #   , EXPIRED_IN_SECONDS

    next()