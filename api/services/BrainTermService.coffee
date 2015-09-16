getQuizs = (gameCode, numQuizs, done)->
  switch gameCode
    when Game.VISIBLE_APIS.DUNG_NOI then BrainAdmin_DungNoiQuizService.getTerm numQuizs, (err, term)->
      if err
        return done(err)
      return done(null, term)

    when Game.VISIBLE_APIS.TIM_BONG then BrainAdmin_TimBongQuizService.getTerm numQuizs, (err, term)->
      if err
        return done(err)
      return done(null, term)

    when Game.VISIBLE_APIS.NHANH_MAT then Admin_NhanhMatBatHinhQuizService.getTerm numQuizs, (err, term)->
      if err
        return done(err)
      return done(null, term)

    when Game.VISIBLE_APIS.PHAN_BIET then BrainAdmin_PhanBietHinhChuQuizService.getTerm numQuizs, (err, term)->
      if err
        return done(err)
      return done(null, term)

    else 
      return done({code: 6059, error: "Invalid Game Code", log: "[BrainTermService.getTerms] ERROR: Invalid Game Code"})

exports.getTerms = (gameList, numQuizs, done)->
  terms = []
  
  async.each gameList, (gameCode, cb)->
    getQuizs gameCode, numQuizs, (err, term)->
      if err
        return cb(err)
      terms.push term
      return cb()
  , (err)->
    if err
      return done(err)
    return done(null, terms)