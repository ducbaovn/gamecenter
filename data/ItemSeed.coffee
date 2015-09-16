require('date-utils')
addSingleItems = (game)=>
  sails.log.info "RUN addSingleItems......................."
  today = new Date()
  data =
    gameCode: game.code
    name: "Huy chương tài ba"
    icon: "/images/HuyChuong.png"
    iconDetail: "/images/HuyChuongView.png"
    description: "Trong sự kiện vinh danh nhân tài, nguời chơi có thể nhận đuợc 'Huy chương tài ba'. Sau khi dùng đuợc cộng 6 điểm skill: 1, điểm kinh nghiệm: 10."
    code: "EXP01"
    exp: 10
    money: 0
    cleverExp: 1
    exactExp: 1
    logicExp: 1
    naturalExp: 1
    socialExp: 1
    langExp: 1
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: false
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.RANDOM
    usageType: Item.USAGE_TYPES.SINGLE
    givenCount: 10000

  callback = (e)->
    sails.log.info e


  Item.create(data).exec(callback)


addPartialItems = (game)=>
  sails.log.info "RUN addPartialItems......................."
  data = [
    gameCode: game.code
    name: "Hộp sữa"
    icon: "/images/HopSua.png"
    iconDetail: "/images/HopSuaView.png"
    description: "Khi kết hợp 10 'Hộp sữa' người chơi có thể ráp thành một chiếc Xe 3 bánh."
    code: "X3B01HS"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: false
    relatedItems: [{code: 'X3B01HS', quantity: 10}]
    compoundItemCode: 'X3B01'
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.RANDOM
    usageType: Item.USAGE_TYPES.PARTIAL
    givenCount: 3000
  ,
    gameCode: game.code
    name: "Bàn đạp"
    icon: "/images/BanDap.png"
    iconDetail: "/images/BanDapView.png"
    description: "Khi kết hợp 1: Khung xe, 2: Bánh xe, 1: Bàn đạp nguời chơi có thể ráp thành một chiếc Xe đạp mini."
    code: "XDMN01BD"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: false
    relatedItems: [
      code: 'XDMN01BD'
      quantity: 1
    ,
      code: 'XDMN01BX'
      quantity: 2
    ,
      code: 'XDMN01KX'
      quantity: 1
    ]
    compoundItemCode: 'XDMN01'
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.RANDOM
    usageType: Item.USAGE_TYPES.PARTIAL
    givenCount: 5000
  ,

    gameCode: game.code
    name: "Bánh xe"
    icon: "/images/BanhXe.png"
    iconDetail: "/images/BanhXeView.png"
    description: "Khi kết hợp 1: Khung xe, 2: Bánh xe, 1: Bàn đạp nguời chơi có thể ráp thành một chiếc Xe đạp mini."
    code: "XDMN01BX"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: false
    relatedItems: [
      code: 'XDMN01BD'
      quantity: 1
    ,
      code: 'XDMN01BX'
      quantity: 2
    ,
      code: 'XDMN01KX'
      quantity: 1
    ]
    compoundItemCode: 'XDMN01'
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.RANDOM
    usageType: Item.USAGE_TYPES.PARTIAL
    givenCount: 1000
  ,
    gameCode: game.code
    name: "Khung xe"
    icon: "/images/SuonXe.png"
    iconDetail: "/images/SuonXeView.png"
    description: "Khi kết hợp 1: Khung xe, 2: Bánh xe, 1: Bàn đạp nguời chơi có thể ráp thành một chiếc Xe đạp mini."
    code: "XDMN01KX"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: false
    relatedItems: [
      code: 'XDMN01BD'
      quantity: 1
    ,
      code: 'XDMN01BX'
      quantity: 2
    ,
      code: 'XDMN01KX'
      quantity: 1
    ]
    compoundItemCode: 'XDMN01'
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.RANDOM
    usageType: Item.USAGE_TYPES.PARTIAL
    givenCount: 5000
  ]

  callback = (e)->
    sails.log.info e

  Item.create(data).exec(callback)


addCompoundItems = (game)=>
  today = new Date()
  data = [
    gameCode: game.code
    name: "Xe 3 bánh"
    icon: "/images/3Banh.png"
    iconDetail: "/images/3BanhView.png"
    description: "Khi kết hợp 10: Hộp sữa người chơi có thể ráp thành một chiếc Xe 3 bánh."
    code: "X3B01"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    isReal: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 3000
    isReal: true
  ,
    gameCode: game.code
    name: "Xe đạp mini"
    icon: "/images/XeMini.png"
    iconDetail: "/images/XeMiniView.png"
    description: "Xe đạp mini được hình thành từ các vật phẩm ghép. Khi sử dụng sẽ nhận được mật mã để đổi lấy xe đạp thật tương đương ở ngoài thực tế."
    code: "XDMN01"
    exp: 0
    money: 0
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: true
  ,
    gameCode: game.code
    name: "Túi tiền thưởng"
    icon: "/images/tuitien100.png"
    iconDetail: "/images/tuitien100_view.png"
    description: "Trong sự kiện người chơi sẽ được tặng Túi tiền thưởng này."
    code: "ENS01"
    exp: 0
    money: 100
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: false
  ,
    gameCode: game.code
    name: "Túi tiền thưởng"
    icon: "/images/tuitien200.png"
    iconDetail: "/images/tuitien200_view.png"
    description: "Trong sự kiện người chơi sẽ được tặng Túi tiền thưởng này."
    code: "ENS02"
    exp: 0
    money: 200
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: false
  ,
    gameCode: game.code
    name: "Túi tiền thưởng"
    icon: "/images/tuitien300.png"
    iconDetail: "/images/tuitien300_view.png"
    description: "Trong sự kiện người chơi sẽ được tặng Túi tiền thưởng này."
    code: "ENS03"
    exp: 0
    money: 300
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: false
  ,
    gameCode: game.code
    name: "Túi tiền thưởng"
    icon: "/images/tuitien400.png"
    iconDetail: "/images/tuitien400_view.png"
    description: "Trong sự kiện người chơi sẽ được tặng Túi tiền thưởng này."
    code: "ENS04"
    exp: 0
    money: 400
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: false
  ,
    gameCode: game.code
    name: "Túi tiền thưởng"
    icon: "/images/tuitien500.png"
    iconDetail: "/images/tuitien500_view.png"
    description: "Trong sự kiện người chơi sẽ được tặng Túi tiền thưởng này."
    code: "ENS05"
    exp: 0
    money: 500
    cleverExp: 0
    exactExp: 0
    logicExp: 0
    naturalExp: 0
    socialExp: 0
    langExp: 0
    energy: 0
    luckyTimes: 0
    isActive: true
    startDate: (new Date('11/01/2014'))
    endDate: (new Date('11/01/2015'))
    offerType: Item.OFFER_TYPES.MANUAL
    usageType: Item.USAGE_TYPES.COMPOUND
    givenCount: 5000
    isReal: false
  ]
  callback = (e)->
    sails.log.info e


  Item.create(data).exec(callback)


exports.execute = (cb)=>
  sails.log.info "ITEM SEED EXECUTING..........................."
  Game.findOne code: Game.VISIBLE_APIS.MATH, (e, game)->
    if e || ! game?
      sails.log.info game
      return

    Item.count (e, cnt)->
      if e
        sails.log.info e
      if cnt == 0
        addSingleItems(game)
        addPartialItems(game)
        addCompoundItems(game)
  return cb(null)
