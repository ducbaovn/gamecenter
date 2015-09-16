exports.list = (params, done) ->  
  if !params.fromDate && !params.toDate
    return done({code: 5126, error: 'Bucket Log: Missing params Time'})

  async.waterfall [
    (cb) ->
      if params.filter?
        userCond = 
          $or: [
            email:
              contains: params.filter
          ,
            nickname:
              contains: params.filter
          ]

        User.find userCond, (err, users)->
          users = _.pluck(users, 'id')
          cb(null, users)

      else
        cb(null, [])
  ,
    (userList, cb) ->

      # build sort condition
      if !params.sortBy || params.sortBy not in ['game', 'reason', 'item']
        params.sortBy = 'createdAt'
      if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
        params.sortOrder = 'desc'
      sortCond = {}
      sortCond[params.sortBy] = params.sortOrder

      # query condition
      query =
        createdAt: {}
      
      if params.gameCode?
        query.gameCode = params.gameCode
      if params.fromDate?
        query.createdAt['>'] = new Date(params.fromDate)
      if params.toDate?
        query.createdAt['<'] = new Date(params.toDate)
      if params.filter?
        query.$or = [
          reason: 
            contains: params.filter
        ]
        if userList && userList.length > 0
          query.$or.push
            user: userList
      
      params.page = parseInt(params.page) || 1
      params.limit = parseInt(params.limit) || 10
      if params.limit > 0
        query.limit = params.limit
        query.skip = params.limit * (params.page - 1)
      
      BucketLog.find query
      .sort(sortCond)
      .populate('user')
      .populate('item')
      .exec (err, logs)->
        if err
          sails.log.error "[UserLog.list] ERROR: could not get user log list ... #{JSON.stringify(err)}"
          return done({code: 5000, error: "could not process"}, null)

        BucketLog.count query, (err, total)->
          if err
            sails.log.error "[UserLog.list] ERROR: could not count user log list ... #{JSON.stringify(err)}"
            return done({code: 5000, error: "could not process"}, null)
          return done(null, {result: logs, total: total})

  ], (err, results) ->
    if err
      return done(err, null)      
    return done(null, results)

