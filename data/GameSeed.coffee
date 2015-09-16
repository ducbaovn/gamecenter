
createGameData = (done)->
  sails.log.info "RUN createGameData.........................."

  domain = 'http://103.19.220.139:7777'
  cats = [
    name: 'Toán'
    ordering: 1
    isActive: true
    games: [
      code: Game.VISIBLE_APIS.MATH
      parent: [Game.VISIBLE_APIS.SMART_PLUS]
      name: 'Toán Thần Tốc'
      description: 'Chơi Toán Thần Tốc, nhận ngay quả khủng'
      icon: "#{domain}/images/games/ToanThanToc.png"
      cover: "#{domain}/images/game-cover/ToanThanToc.png"
      ordering: 1
      isActive: true
      packageUrl: 
        ios: 'http://smartplus.nahi.vn/ios/toanthantoc'
        android: 'http://smartplus.nahi.vn/android/toanthantoc'
      packageId: 
        ios: 'ToanThanToc'
        android: 'vn.nahi.toanthantoc'
    ]
  ,
    name: 'Trí não'
    ordering: 2
    isActive: true
    games: [
      code: Game.VISIBLE_APIS.BRAIN
      parent: [Game.VISIBLE_APIS.SMART_PLUS]
      name: 'Đấu trí'
      description: 'Cùng chơi Đấu Trí, nhận nhiều quà hay'
      icon: "#{domain}/images/games/DauTri.png"
      cover: "#{domain}/images/game-cover/DauTri.png"      
      ordering: 1
      isActive: true
      packageUrl: 
        ios: 'http://smartplus.nahi.vn/ios/dautri'
        android: 'http://smartplus.nahi.vn/android/dautri'
      packageId: 
        ios: 'ToanThanToc'
        android: 'vn.nahi.toanthantoc'
    ,
      code: Game.VISIBLE_APIS.DUNG_NOI
      parent: [Game.VISIBLE_APIS.BRAIN, Game.VISIBLE_APIS.DUEL]
      name: 'Đúng nơi đúng chỗ'
      description: 'Mini Game Đúng nơi đúng chỗ'
      icon: "#{domain}/images/games/miniGame.png"
      cover: "#{domain}/images/game-cover/DauTri.png"      
      ordering: 1
      isActive: true
      naturalExpPreset: 2
      socialExpPreset: 1
      langExpPreset: 2
    ,
      code: Game.VISIBLE_APIS.TIM_BONG
      parent: [Game.VISIBLE_APIS.BRAIN, Game.VISIBLE_APIS.DUEL]
      name: 'Tìm bóng cho hình'
      description: 'Mini Game Tìm bóng cho hình'
      icon: "#{domain}/images/games/miniGame.png"
      cover: "#{domain}/images/game-cover/DauTri.png"    
      ordering: 2  
      isActive: true
      naturalExpPreset: 1
      socialExpPreset: 3
      langExpPreset: 1
    ,
      code: Game.VISIBLE_APIS.NHANH_MAT
      parent: [Game.VISIBLE_APIS.BRAIN, Game.VISIBLE_APIS.DUEL]
      name: 'Nhanh mắt bắt hình'
      description: 'Mini Game Nhanh mắt bắt hình'
      icon: "#{domain}/images/games/miniGame.png"
      cover: "#{domain}/images/game-cover/DauTri.png"      
      ordering: 3
      isActive: true
      naturalExpPreset: 1
      socialExpPreset: 3
      langExpPreset: 0
    ,
      code: Game.VISIBLE_APIS.PHAN_BIET
      parent: [Game.VISIBLE_APIS.BRAIN, Game.VISIBLE_APIS.DUEL]
      name: 'Phân biệt hình chữ'
      description: 'Mini Game Phân biệt hình chữ'
      icon: "#{domain}/images/games/miniGame.png"
      cover: "#{domain}/images/game-cover/DauTri.png"    
      ordering: 4  
      isActive: true
      naturalExpPreset: 2
      socialExpPreset: 1
      langExpPreset: 2
    ] 
  ,
    name: 'So tài'
    ordering: 0
    isActive: false
    games: [
      code: Game.VISIBLE_APIS.DUEL     
      name: 'So tài'
      description: "Hai người chơi so tài với nhau."
      icon: "#{domain}/images/games/SoTai.png"
      isActive: false
    ]
  ,
    name: 'Game khác'
    ordering: 0
    isActive: false
    games: [
      code: Game.VISIBLE_APIS.SMART_PLUS     
      name: 'Smart Plus'
      description: "Smart Plus"      
      icon: "#{domain}/images/games/SmartPlus.png"
      isActive: false
    ,
      code: Game.VISIBLE_APIS.STAR_GARDEN     
      name: 'Star Garden'
      description: "Star Garden là một ứng dụng của Công ty Cổ phần NAHI. Đây là ứng dụng cho phép bạn có thể xem các quảng cáo để kiếm Sao."      
      icon: "#{domain}/images/games/ToanThanToc.png"
      isActive: false
    ]
  ]

  GameCategory.count (err, cnt) ->
    _.forEach cats, (cat) ->
      GameCategory.create cat, (err, catObj) ->
        sails.log.info err if err          
        _.forEach cat.games, (game) ->
          game.category = catObj.id
          Game.create game, (err, gameObj) ->
            sails.log.info err if err
            

exports.execute = (cb)=>
  sails.log.info "GAME SEED EXECUTING..........................."
  Game.count (err, cnt) ->
    sails.log.info err if err          
    if cnt == 0  
      createGameData(cb)
  
  return cb(null)
