module.exports =
  schema: true
  autoCreatedAt: false
  autoUpdatedAt: true
  attributes:
    user:
      model: 'user'
      required: true
      unique: true
      index: true

    receiveValue:
      type: 'integer'
      defaultsTo: 0
    
    receivedCount:
      type: 'integer'
      defaultsTo: 0

    lastReceivedTime:
      type: 'datetime'

    donateValue:
      type: 'integer'
      defaultsTo: 0

    donatedCount:
      type: 'integer'
      defaultsTo: 0

    lastDonatedTime:
      type: 'datetime'

    #====== DONATE rice/stars for others ========#
    # {
    #   receiver: 'user',
    #   note: 'message',
    #   stars: '100xx',
    #   time: 'Datetime'
    # }
    donating:
      type: 'array'


    #====== RECEIVE rice/stars from others ========#
    # {
    #   sender: 'user',
    #   note: 'message',
    #   stars: '100xx',
    #   time: 'Datetime'
    # }
    receiving:
      type: 'array'
