exports.getUserLevel = (userExp, done)->
  Level.findOne {exp: {'<=': userExp}, type: Level.TYPE.USER_LEVEL}
  .sort(name: 'desc')
  .exec (err, level) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[LevelService.getUserLevel] ERROR: Could not process - get Level... #{err}"}, null)
    return done(null, level.name)

exports.getSkillLevel = (skillExp, done)->
  Level.findOne {exp: {'<=': skillExp}, type: Level.TYPE.SKILL_LEVEL}
  .sort(name: 'desc')
  .exec (err, level) ->
    if err
      return done({code: 5000, error: 'Could not process', log: "[LevelService.getUserLevel] ERROR: Could not process - get Level... #{err}"}, null)
    return done(null, level.name)