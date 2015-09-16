 # MathScore.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

MATH_MODES = require('./Configuration').MATH_MODES
Game = require('./Game')

MATH_OPERATORS = [ '1000', 
              '1100', 
              '1010', 
              '1001', 
              '1110', 
              '1101', 
              '1011', 
              '1111', 
              '0100', 
              '0010', 
              '0001', 
              '0110', 
              '0101', 
              '0011', 
              '0111'
            ]
FIXED =
  SCORE: 'score'
  TIME: 'time'

module.exports =
  MATH_MODES: MATH_MODES
  MATH_OPERATORS: MATH_OPERATORS
  FIXED: FIXED
  attributes:
    user:
      model: 'user'
      required: true

    gameCode:
      type: 'string'
      required: true
      enum: _.values(Game.VISIBLE_APIS)

    extends:
      type: 'json'

    fixed:
      type: 'string'
      required: true
      enum: _.values(FIXED)

    score:
      type: 'integer'
      required: true

    time:
      type: 'integer'
      required: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      # delete obj.user
      obj

  afterCreate: (values, next)->
    sails.log.info values
    next()    
  afterUpdate: (values, next)->
    sails.log.info 'afterUpdate'
    sails.log.info values
    next()              