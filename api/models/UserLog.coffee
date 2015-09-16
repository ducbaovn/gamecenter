CATEGORY =
  STAR: 'STAR'
  EXP: 'EXP'
  ENERGY: 'ENERGY'
  MONEY: 'MONEY'
  TIME: 'TIME'

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: false
  CATEGORY: CATEGORY
  
  attributes:
    user:
      model: 'user'
      required: true

    gameCode:
      type: 'string'

    category:
      type: 'string'
      required: true
      enum: _.values(CATEGORY)

    valueChange:
      type: 'float'
      defaultsTo: 0.0

    reason:
      type: 'string'
