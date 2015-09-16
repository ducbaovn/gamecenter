
module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: false
  
  attributes:
    user:
      model: 'user'
      required: true

    gameCode:
      type: 'string'

    item:
      model: 'item'
      required: true

    valueChange:
      type: 'integer'
      required: true

    reason:
      type: 'string'
