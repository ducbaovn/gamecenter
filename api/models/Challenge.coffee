# MathChallenge.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/#!documentation/models

_ = require('lodash')
Game = require('./Game')
require('date-utils')

TYPE = 
  FRIEND: 'FRIEND'
  WORLD: 'WORLD'
  OPTION: 'OPTION'

FRIEND_COST = 0.3
WORLD_COST = 0.2
MAX_DAYS_EXPIRED = 3
MIN_BET = 100
MAX_BET = 99999
FEE_PERCENT = 0.05

module.exports =
  TYPE: TYPE
  FRIEND_COST: FRIEND_COST
  WORLD_COST: WORLD_COST
  MIN_BET: MIN_BET
  MAX_BET: MAX_BET
  MAX_DAYS_EXPIRED: MAX_DAYS_EXPIRED
  FEE_PERCENT : FEE_PERCENT
  attributes:
    gameCode:
      type: 'string'
      required: true
      enum: _.values(Game.VISIBLE_APIS)

    user:
      model: 'user'
      required: true

    # title:
    #   type: 'string'
    #   required: true

    # content:
    #   type: 'string'

    imageUrl:
      type: 'string'
      required: true

    isHolding:
      type: 'boolean'
      defaultsTo: false

    # num of play the game
    availTimes:
      type: 'integer'
      required: true

    playsCount:
      type: 'integer'
      # required: true
      defaultsTo: 0
    
    failuresCount:
      type: 'integer'
      defaultsTo: 0

    # time challenge is expired
    expiredAt:
      type: 'datetime'
      required: true
      before: new Date().addDays(MAX_DAYS_EXPIRED)
      after: new Date()

    moneyPerOne:
      type: 'integer'
      required: true
      min: MIN_BET
      max: MAX_BET

    type:
      type: 'string'
      required: true

    target:
      collection: 'user'
      via: 'targetedChallenge'

    score:
      model: 'Score'
      required: true

    remainingTimes: ()->
      this.availTimes - this.failuresCount

    remainingMoney: ()->
      this.remainingTimes() * this.moneyPerOne

    totalMoney: ()->
      this.moneyPerOne * this.availTimes
    
    costAmount: ()->
      if this.target == TARGETS.FRIEND
        Math.ceil(this.totalMoney() * (1+FRIEND_COST))
      else
        Math.ceil(this.totalMoney() * (1+WORLD_COST))

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      obj