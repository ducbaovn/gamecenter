checkInfo = (gameCode, info, done)->
  switch gameCode
    when Game.VISIBLE_APIS.MATH
      if !info.mode || !info.operator
        return done({code: 6067, error: "Missing params", log: "[ScoreService.add] ERROR: Missing params"})
      if info.mode not in _.values(Score.MATH_MODES)
        return done({code: 6066, error: 'Invalid Math Mode', log: "[ScoreService.add] ERROR: Invalid Math Mode"})
      if info.operator not in _.values(Score.MATH_OPERATORS)
        return done({code: 6066, error: 'Invalid Math Operator', log: "[ScoreService.add] ERROR: Invalid Math Operator"})
      return done()
        
    when Game.VISIBLE_APIS.BRAIN
      if !info.miniGameCode
        return done({code: 6067, error: "Missing params", log: "[ScoreService.add] ERROR: Missing params"})
      if info.miniGameCode not in _.values(Game.BRAIN_MINIGAMECODE)
        return done({code: 6066, error: 'Invalid Mini Game', log: "[ScoreService.add] ERROR: Invalid Mini Game"})
      return done()

    else
      return done({code: 6066, error: "Invalid Game Code", log: "[ScoreService.add] ERROR: Invalid Game Code"})

exports.add = (params, done)->
  if !params.user || !params.gameCode || !params.info || !params.score || !params.time
    return done({code: 6067, error: "Missing params", log: "[ScoreService.add] ERROR: Missing params"})
  params.fixed = params.fixed || Score.FIXED.TIME

  if typeof params.info != 'object'
    try
      params.info = JSON.parse(params.info)
    catch err
      return done({code: 6068, error: "Could not parse JSON", log: "[ScoreService.add] ERROR: Could not parse JSON params.info"})
    
  checkInfo params.gameCode, params.info, (err)->
    if err
      return done(err)
    Score.findOne params, (err, score)->
      if err
        return done({code: 5000, error: "Could not process", log: "[ScoreService.add] ERROR: Could not process - get Score... #{err}"})
      if !score
        return Score.create params, (e, sc)->
          if err
             return done({code: 5000, error: "Could not process", log: "[ScoreService.add] ERROR: Could not process - create Score... #{err}"})
          return done(null, sc)
      return done(null, score)

exports.remove = (params, done)->
  if !params.id
    return done({code: 6067, error: "Missing params id", log: "[ScoreService.remove] ERROR: Missing params id"})
  Score.destroy id: params.id, (err, score)->
    if err
      return done({code: 5000, error: "Could not process", log: "[ScoreService.remove] ERROR: Could not process - destroy Score... #{err}"})
    return done(null, {success: 'Remove Score successful.'})

exports.me = (params, done)->
  if !params.user
    return done({code: 6067, error: "Missing params user", log: "[ScoreService.me] ERROR: Missing params user"})
  page = parseInt(params.page) || 1
  limit = parseInt(params.limit) || 10
  skip = page * limit

  cond =
    user: params.user.id
  if limit > 0
    cond.skip = skip
    cond.limit = limit

  if !params.sortBy && params.sortBy not in ['time', 'score', 'fixed']
    params.sortBy = 'updatedAt'
  if !params.orderBy && params.orderBy not in ['desc', 'asc']
    params.orderBy = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.orderBy

  Score.find cond
  .sort(sortCond)
  .exec (err, scores)->
    if err
      return done({code: 5000, error: "Could not process", log: "[ScoreService.me] ERROR: Could not process - get Score... #{err}"})
    Score.count cond, (err, total)->
      if err
        return done({code: 5000, error: "Could not process", log: "[ScoreService.me] ERROR: Could not process - count Score... #{err}"})
      return done(null, {result: scores, total: total})