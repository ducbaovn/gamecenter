 # Playing.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

Game = require('./Game')
module.exports =
  schema: true

  attributes:
    player:
      model: 'user'
      required: true
    
    gameCode:
      type: 'string'
      required: true
      unique: true
      enum: _.values(Game.VISIBLE_APIS)

    # Einstein
    exp:
      type: 'float'
      defaultsTo: 0
    
    # this field is deprecated (use money item instead of money value)
    money:
      type: 'integer'
      defaultsTo: 0

    studyExp:
      type: 'float'
      defaultsTo: 0
    cleverExp:
      type: 'float'
      defaultsTo: 0
    exactExp:
      type: 'float'
      defaultsTo: 0
    logicExp:
      type: 'float'
      defaultsTo: 0
    naturalExp:
      type: 'float'
      defaultsTo: 0
    socialExp:
      type: 'float'
      defaultsTo: 0
    langExp:
      type: 'float'
      defaultsTo: 0
    memoryExp:
      type: 'float'
      defaultsTo: 0
    observationExp:
      type: 'float'
      defaultsTo: 0
    judgementExp:
      type: 'float'
      defaultsTo: 0

    lastPlayed:
      type: 'datetime'
      defaultsTo: new Date()
