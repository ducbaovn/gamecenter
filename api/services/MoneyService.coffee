exports.syncMoney = (user, done)=>
  WalletService.viewMoney user.token, (e, obj)->
    if e
      return done(e, null)
    user.starMoney = obj.star
    user.rubyMoney = obj.ruby
    User.update {id: user.id}, {starMoney: user.starMoney, rubyMoney: user.rubyMoney}, (e, us)->
      sails.log.info "[MoneyService]: syncMoney(#{user.id}, #{JSON.stringify(obj)}) with #{JSON.stringify(e)}"
      return done(null, us)


# INPUTS
# user: userObject
# params.star
# params.itemid
# params.project
# params.note
exports.descStars = (user, params, done)=>
  pr =
    token: user.token
    star: params.star
    itemid: params.itemid
    project: (params.project || user.package)
    note: params.note

  console.log pr
  WalletService.pickStar pr, (err, rt)->
    if err
      return done(err, null)

    exports.syncMoney(user, done)

    logData =
      user: user
      gameCode: params.gameCode
      category: UserLog.CATEGORY.STAR
      valueChange: -params.star
      reason: params.note
    UserLog.create logData, (err, userLog)->
      if err
        sails.log.info "[MoneyService.descStars] ERROR: Could not process - create UserLog... #{err}"

exports.descRubys = (user, params, done)=>
  pr =
    token: user.token
    ruby: params.ruby
    itemid: params.itemid
    project: params.project
    note: params.note

  WalletService.pickRuby pr, (e, rt)->
    if e
      return done(e, null)

    exports.syncMoney(user, done)

exports.rubyToStars = (user, params, done)=>
  pr =
    token: user.token
    ruby: params.ruby
    project: params.project
    note: params.note

  WalletService.changeRubyToStar pr, (e, rt)->
    if e
      return done(e, null)

    exports.syncMoney(user, done)


# params:
#   star
#   project
#   note
exports.incStars = (user, params, done)=>
  pr =
    token: user.token
    star: params.star
    project: (params.project || user.package)
    note: params.note

  WalletService.addStar pr, (e, rt)->
    if e
      return done(e, null)    

    exports.syncMoney(user, done)
    
    logData =
      user: user
      gameCode: params.gameCode
      category: UserLog.CATEGORY.STAR
      valueChange: params.star
      reason: params.note
    UserLog.create logData, (err, userLog)->
      if err
        sails.log.info "[MoneyService.descStars] ERROR: Could not process - create UserLog... #{err}"

#===INPUTS===
# user: userObject
# stars: num of star
#===OUTPUTS=====
# true/false
exports.verifyStarMoney = (user, stars, done)=>
  exports.syncMoney user, (e, obj)->
    if e
      return done(false)
    if obj.starMoney < stars
      return done(false)
    return done(true)

exports.verifyRubyMoney = (user, rubys, done)=>
  exports.syncMoney user, (e, obj)->
    if e
      return done(false)
    if obj.starMoney < rubys
      return done(false)
    return done(true)

# exports.incUserStarMoney = (userid, stars)=>
#   User.findOne userid, (e, user)->
#     if e
#       return false
#     if ! user?
#       return false

#     sails.log.debug("incUserStarMoney(#{userid}, #{stars})")
#     sails.log.info user.starMoney
#     newStars = user.starMoney + stars
#     sails.log.info newStars
#     User.update {id: userid}, {starMoney: newStars}, (e, us)->
#       if e
#         return false
        
#       return true

# exports.descUserStarMoney = (userid, stars)=>
#   User.findOne userid, (e, user)->
#     if e
#       return false
#     if ! user?
#       return false

#     newStars = user.starMoney - stars
#     if newStars < 0
#       newStars = 0
#     User.update {id: userid}, {starMoney: newStars}, (e, us)->
#       if e
#         return false
        
#       return true