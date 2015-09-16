_ = require('lodash')
async = require('async')

trackingSender = (params)->
  sails.log.info 'trackingSender........'
  stars = parseInt(params.stars)

  Donation.findOne {user: params.sender.id}, (e, tracking)->
    if e
      return false
    if ! tracking
      dataSender = 
        user: params.sender.id
        receiveValue: 0
        receivedCount: 0
        donateValue: stars
        donatedCount: 1
        lastDonatedTime: new Date()
        donating: [
          receiver: params.receiver.id,
          note: params.note,
          stars: stars,
          time: new Date()
        ]
        receiving: []


      Donation.create dataSender, (e, d)->
        sails.log.info d
      return true

    donating = tracking.donating || []
    donatedCount = tracking.donatedCount || 0
    donateValue = tracking.donateValue || 0
    donating.push({receiver: params.receiver.id, note: params.note, stars: stars, time: new Date()})
    data = 
      donateValue: donateValue+stars
      lastDonatedTime: new Date()
      donatedCount: donatedCount+1
      donating: donating

    Donation.update {id: tracking.id}, data, (e, dns)->
      sails.log.info e
      sails.log.info dns

    return true

trackingReceiver = (params)->
  sails.log.info 'trackingReceiver...................'
  stars = parseInt(params.stars)
  Donation.findOne {user: params.receiver.id}, (e, tracking)->
    if e
      return false

    if ! tracking
      dataReceiver =
        user: params.receiver.id
        receiveValue: stars
        receivedCount: 1
        lastReceivedTime: new Date()
        donateValue: 0
        donatedCount: 0
        donating: []
        receiving: [
          sender: params.sender.id,
          note: params.note,
          stars: stars,
          time: new Date()
        ]

      Donation.create dataReceiver, (e, dnr)->
        # TODO
        sails.log.info e
        sails.log.info dnr
      return true

    receiveValue = tracking.receiveValue || 0
    receivedCount = tracking.receivedCount || 0
    receiving = tracking.receiving || []
    receiving.push({sender: params.sender.id, note: params.note, stars: stars, time: new Date()})
    data =
      receiveValue: receiveValue + stars
      receivedCount: receivedCount + 1
      lastReceivedTime: new Date()
      receiving: receiving

    Donation.update {id: tracking.id}, data, (e, dnr)->
      # TODO
      sails.log.info e
      sails.log.info dnr

    return true

trackingDonation = (params)->
  sails.log.info "trackingDonation......"
  trackingSender(params)
  trackingReceiver(params)

donateToUser = (params, cb)->
  user = params.user
  receiver = params.receiver
  stars = params.stars
  note = params.note
  itemid = params.itemid || "TODO"
  project = params.project || "GAMECENTER"
  Game.findOne code: Game.VISIBLE_APIS.SMART_PLUS, (e,game)->
    if e
      sails.log.info e

    MoneyService.verifyStarMoney user, stars, (isValid)->
      if !isValid
        return cb('Không đủ số sao cần thiết', false)

      sendData =
        star: stars
        itemid: itemid
        project: project
        note: note
        gameCode: game.code
      sendData.note = "Góp gạo: #{sendData.note}"
      MoneyService.descStars user, sendData, (e, send1)->
        if e
          return cb('Không thể thực hiện được thao tác góp gạo', false)

        receiveData =
          star: stars
          itemid: itemid
          project: project
          note: note
          gameCode: game.code
        receiveData.note = "Nhận được gạo: #{receiveData.note}"
        MoneyService.incStars receiver, receiveData, (e, rec1)->
          if e
            # TODO should change return note
            receiveData.note = "Trả lại gạo đã góp: #{receiveData.note}"
            MoneyService.incStars user, receiveData, (e, u)->
              sails.log.info e

            return cb('Không thực hiện được chuyển gạo cho người nhận', false)

          trackingDonation({sender: user, receiver: receiver, stars: stars, note: note})
        
        return cb(null, true)


exports.gcTransferStarsToFriend = (req, cb)->
  user = req.user
  receiverId = req.param('receiver')
  stars = req.param('stars') || 0
  stars = parseInt(stars)
  if stars <= 0
    return cb("Số sao phải lớn hơn 0", false)

  User.findOne {id: receiverId}, (e, receiver)->
    if e || !receiver
      return cb("Không tìm thấy người nhận", false)
    data =
      user: user
      receiver: receiver
      stars: stars
      note: "`#{user.nickname}` góp #{stars} sao cho `#{receiver.nickname}`"
      itemid: null
      project: null
    
    donateToUser data, (e, isValid)->
      return cb(e, isValid)



# should authorize with webtoken
exports.webTransferStarsToFriend = (req, cb)->
  user = req.user
  receiverId = req.param('receiver')
  stars = req.param('stars') || 0
  stars = parseInt(stars)
  if stars <= 0
    return cb({code: 5105, error: "Số sao phải lớn hơn 0"}, false)

  User.findOne {webId: receiverId}, (e, receiver)->
    if e || !receiver
      return cb({code: 5106, error: "Không tìm thấy người nhận"}, false)
    data =
      user: user
      receiver: receiver
      stars: stars
      note: "`#{user.nickname}` góp #{stars} sao cho `#{receiver.nickname}`"
      itemid: null
      project: null
    
    donateToUser data, (e, isValid)->
      return cb(e, isValid)




