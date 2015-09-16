async = require('async')

createMiniGame = (dauTri, done)->
  data = [
    code: 'DT01'
    name: Game.BRAIN_MINIGAME.DUNG_NOI
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT02'
    name: Game.BRAIN_MINIGAME.TIM_BONG
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT03'
    name: Game.BRAIN_MINIGAME.NHANH_MAT
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT04'
    name: Game.BRAIN_MINIGAME.PHAN_BIET
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT05'
    name: Game.BRAIN_MINIGAME.TINH_NHAM
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT06'
    name: Game.BRAIN_MINIGAME.NHIEU_IT
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT07'
    name: Game.BRAIN_MINIGAME.TINH_NHANH
    icon: 'chua co'
    parent: dauTri.id
  ,
    code: 'DT08'
    name: Game.BRAIN_MINIGAME.NHANH_TAY
    icon: 'chua co'
    parent: dauTri.id
  ]

  Game.create data, (e, games)->
    if e 
      return done(e, null)
    return done(null, games)

createImageCategory = (games, done)->
  data = []
  _.forEach games, (game)->
    _.forEach ImageCategory.CATEGORY, (category)->
      data.push {name: category, game: game.id}
  ImageCategory.create data, (e, category)->
    if e
      return done(e, null)
    return done(null, category)

exports.execute = (cb)=>
  sails.log.info "MINIGAME_IMAGECATEGORY SEED EXECUTING..........................."

  # Game.create
  #   code: 'DT'
  #   name: 'Đấu Trí'
  #   icon: 'chua co'
  # , (err, game)->
  #   # newGame = [
  #   # ]
  #   createMiniGame game, (e, newgames)->
  #     if e
  #       sails.log.info e
  #       return cb(false)
  #     createImageCategory newgames, (e, category)->
  #       if e
  #         sails.log.info e
  #         return cb(false)
  cb(true)