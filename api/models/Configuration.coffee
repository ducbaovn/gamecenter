_ = require('lodash')


MATH_MODES = 
  EASY: 'EASY'
  MEDIUM: 'MEDIUM'
  HARD: 'HARD'

BRAIN_MODES = 
  NORMAL: 'NORMAL'
  RANDOM: 'RANDOM'

module.exports =
  MATH_MODES: MATH_MODES
  BRAIN_MODES: BRAIN_MODES
  
  autoCreatedAt: false
  autoUpdatedAt: false  
  attributes:
    # if gamecode = null, this is common configuration
    gamecode:
      type: 'string'

    title: 
      type: 'string'

    config:
      type: 'json'
      defaultsTo: {}