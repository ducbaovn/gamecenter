createLevelData = (done)->
  sails.log.info "RUN createLevelData..........................."
  Level.count (e, ct)->
    if(ct > 0)
      return 0

    callback = (e)->
      sails.log.info "imported levels"
      sails.log.info e
    userLevel = _.cloneDeep Level.DEFAULT_LEVELS
    skillLevel = _.map Level.DEFAULT_LEVELS, (n)->
      n.exp = n.exp/10
      n.type = 2
      return n
    Level.DEFAULT_LEVELS = userLevel.concat(skillLevel)
    Level.create(Level.DEFAULT_LEVELS).exec(callback)

exports.execute = (cb)=>
  sails.log.info "LEVEL SEED EXECUTING..........................."
  createLevelData(cb)
  return cb(null)
