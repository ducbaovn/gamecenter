# MathChallenge.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/#!documentation/models

_ = require('lodash')

MATH_MODES = require('./Configuration').MATH_MODES
OPERATORS = require('./MathScore').OPERATORS

module.exports =
  attributes:
    challenge:
      model: 'challenge'
      required: true

    mode:
      type: 'string'
      required: true
      enum: MATH_MODES

    operator:
      type: 'string'
      required: true
      enum: OPERATORS
      
    time:
      type: 'integer'
      required: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.createdAt
      delete obj.updatedAt
      obj


