
module.exports =
  
  online: (req, res)->
    params = req.allParams()
    if !params.gamecode
      return res.badRequest({code: 6208, error: 'missing param game code'})

    Game.findOne code: params.gamecode, (err, game) ->
      if err
        sails.log.info err
        return res.badRequest({code: 5000, error: 'Could not process'})
      if !game
        return res.badRequest({code: 6209, error: 'game code is not exists'})

      # build condition  
      page = parseInt(params.page) || 1    
      limit = parseInt(params.limit) || 20
      skip = limit * (page - 1)

      cond = {}

      User.native (err, collection) ->
        if err
          sails.log.info err
          return res.badRequest({code: 5000, error: 'Could not process'})
                
        collection.find cond,
          id: true
          email: true
          fullname: true
          nickname: true
          avatar_url: true
          onlineStatus: true
          level: true
          gender: true
          rateOnline: true
        .sort({ 'rateOnline.rate': -1, 'rateOnline.lastPlayed': 1 })
        .skip(skip).limit(limit)
        .toArray (err, users) ->
          if err
            sails.log.info err
            return res.badRequest({code: 5000, error: 'Could not process'})

          async.map users, (user, cb) ->  
            user.id = user._id.toString()            
            user.winOnline = (user.rateOnline?[params.gamecode]?.win || 0)
            user.loseOnline = (user.rateOnline?[params.gamecode]?.lose || 0)
            user.rateOnline = (user.rateOnline?[params.gamecode]?.rate || 0)
            delete user._id
            return cb(null, user)
          , (err, list) ->
            if err
              sails.log.info err
              return res.badRequest({code: 5000, error: 'Could not process'})
            return res.ok(list)