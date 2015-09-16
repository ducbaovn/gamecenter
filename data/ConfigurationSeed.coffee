
createConfigData = (done)->
  data = [
    gamecode: Game.VISIBLE_APIS.SMART_PLUS
    title: 'Cấu hình chung'
    config: 
      appVersion: "1.0.0"
      energyPerDay: 480
      changeNicknameCost: 50
      challengeFriendCostPercent: 30
      challengeGlobalCostPercent: 20
  ,
    gamecode: Game.VISIBLE_APIS.MATH
    title: 'Cấu hình Toán Thần Tốc'
    config: 
      expPerPlay: 100 
      energyPerPlay: 10  
      starSingleMode: 10 
      onlineMathFeePercent: 10
      'EASY':  
        einsteinRate: 2
        minEinsteinRandomFactor: 3
        maxEinsteinRandomFactor: 7      
      'MEDIUM':
        einsteinRate: 3
        minEinsteinRandomFactor: 3
        maxEinsteinRandomFactor: 7      
      'HARD':
        einsteinRate: 5
        minEinsteinRandomFactor: 3
        maxEinsteinRandomFactor: 7     
  ,
    gamecode: Game.VISIBLE_APIS.BRAIN
    title: 'Cấu hình Đấu trí'
    config: 
      expPerPlay: 100 
      energyPerPlay: 10   
      starSingleMode: 10 
  ,
    gamecode: Game.VISIBLE_APIS.DUEL
    title: 'Cấu hình So tài'
    config: 
      expPerPlay: 100 
      energyPerPlay: 10   
  ]

  Configuration.create data, (err, conf) ->
    sails.log.info err if err

exports.execute = (cb) =>
  sails.log.info "GAME CONFIGURATION SEED EXECUTING..........................."
  Configuration.count (err, cnt)->
    if err
      sails.log.info err
    if cnt == 0  
      createConfigData(cb)
  
  return cb(null)
