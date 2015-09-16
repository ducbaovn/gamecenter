async = require('async')
ObjectId = require('mongodb').ObjectID

exports.view = (params, done) ->
  if !params.user
    return done({code: 5125, error: 'User Log: Missing params User ID'})
  if !params.fromDate && !params.toDate
    return done({code: 5126, error: 'User Log: Missing params Time'})

  # sort condition
  if !params.sortBy || params.sortBy not in ['game', 'reason', 'category']
    params.sortBy = 'createdAt'
  if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
    params.sortOrder = 'desc'
  sortCond = {}
  sortCond[params.sortBy] = params.sortOrder

  # query condition
  query =
    user: params.user
    createdAt: {}

  if params.gameCode?
    query.gameCode= params.gameCode
  if params.fromDate?
    query.createdAt['>'] = new Date(params.fromDate)
  if params.toDate?
    query.createdAt['<'] = new Date(params.toDate)
  if params.reason?
    query.reason = 
      contains: params.reason
  if params.category?
    query.category = params.category

  params.page = parseInt(params.page) || 1
  params.limit = parseInt(params.limit) || 10
  if params.limit > 0
    query.limit = params.limit
    query.skip = params.limit * (params.page - 1)

  UserLog.find query
  .sort(sortCond)
  .populate('user')
  .exec (err, userLog) ->    
    if err
      return done({code: 5000, error: err}, null)
    UserLog.count query, (err, total)->
      if err
        sails.log.error "[UserLog.list] ERROR: could not count user log list ... #{JSON.stringify(err)}"
        return done({code: 5000, error: "could not process"}, null)
      return done(null, {result: userLog, total: total})


exports.list = (params, done) ->  
  if !params.fromDate && !params.toDate
    return done({code: 5126, error: 'User Log: Missing params Time'})

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
      if !params.sortBy || params.sortBy not in ['game', 'reason', 'category']
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

      if params.category?
        query.category = params.category
      
      params.page = parseInt(params.page) || 1
      params.limit = parseInt(params.limit) || 10
      if params.limit > 0
        query.limit = params.limit
        query.skip = params.limit * (params.page - 1)
      
      UserLog.find query
      .sort(sortCond)
      .populate('user')
      .exec (err, logs)->
        if err
          sails.log.error "[UserLog.list] ERROR: could not get user log list ... #{JSON.stringify(err)}"
          return done({code: 5000, error: "could not process"}, null)

        UserLog.count query, (err, total)->
          if err
            sails.log.error "[UserLog.list] ERROR: could not count user log list ... #{JSON.stringify(err)}"
            return done({code: 5000, error: "could not process"}, null)
          return done(null, {result: logs, total: total})

  ], (err, results) ->
    if err
      return done(err, null)      
    return done(null, results)


exports.report = (params, done) ->
  if !params.fromDate && !params.toDate
    return done({code: 5126, error: 'User Log: Missing params Time'})

  async.waterfall [
    (cb) ->
      if params.filter?
        userCond = 
          $or: [
            email:
              $regex: params.filter
              $options: 'i'
          ,
            nickname:
              $regex: params.filter
              $options: 'i'
          ]

        User.native (err, collections) ->
          if err
            sails.log.error "[UserLog.report] ERROR: could not native ... #{JSON.stringify(err)}"
            return cb({code: 5000, error: "could not process"}, null)

          collections.find userCond, 
            _id: true
          .toArray (err, users)->
            users = _.pluck(users, '_id')
            cb(null, users)

      else
        cb(null, [])
  ,
    (userList, cb) ->
      query = []
      match = 
        $match:
          category: params.category
          createdAt: {}

      # query condition
      if params.gameCode?
        match.$match.gameCode = params.gameCode
      if params.fromDate?
        match.$match.createdAt.$gte = new Date(params.fromDate)
      if params.toDate?
        match.$match.createdAt.$lte = new Date(params.toDate)
      if params.filter?
        match.$match.$or = [
          reason:
            $regex: params.filter
            $options: 'i'
        ]
        if userList && userList.length > 0
          match.$match.$or.push
            user:
              $in: userList

      query.push match
      
      # group by
      group =
        $group:
          _id:
            user: "$user"
          sumChange:
            $sum: "$valueChange"
      query.push group

      # sort condition
      sort = {}
      if !params.sortBy || params.sortBy not in ['user','sumChange']
        params.sortBy = 'sumChange'
      if !params.sortOrder || params.sortOrder not in [-1, 1]
        params.sortOrder = -1
      sort[params.sortBy] = params.sortOrder
      query.push $sort: sort

      # pagination
      params.page = parseInt(params.page) || 1
      params.limit = parseInt(params.limit) || 10
      if params.limit > 0
        params.skip = params.limit * (params.page - 1)
        query.push $skip: params.skip
        query.push $limit: params.limit

      # count 
      count =
        $group:
          _id: null
          count:
            $sum: 1
     
      UserLog.native (err, collection1) ->
        if err
          sails.log.error "[UserLog.report] ERROR: could not native ... #{JSON.stringify(err)}"
          return cb({code: 5000, error: "could not process"}, null)
        collection1.aggregate [match, group, count], (err, result)->
          if err
            sails.log.error "[UserLog.report] ERROR: could not native ... #{JSON.stringify(err)}"
            return cb({code: 5000, error: "could not process"}, null)
          
          total = (if result[0]? then result[0].count else 0)

          if total == 0
            return cb(null, {result: [], total: total})
          
          UserLog.native (err, collection2)->
            if err
              sails.log.error "[UserLog.report] ERROR: could not native ... #{JSON.stringify(err)}"
              return cb({code: 5000, error: "could not process"}, null)
            collection2.aggregate query, (err, logs)->
              if err
                sails.log.error "[UserLog.report] ERROR: could not get user log list ... #{JSON.stringify(err)}"
                return cb({code: 5000, error: "could not process"}, null)
              
              async.each logs, (log, cb)->
                User.findOne id: log._id.user.toString(), (err, user)->
                  if err
                    sails.log.error "[UserLog.report] ERROR: could not get user ... #{JSON.stringify(err)}"
                    return cb(err)
                  delete log._id
                  log.user = user
                  return cb()
              , (err)->
                if err
                  sails.log.error err
                  return cb(err, null)
                return cb(null, {result: logs, total: total})

  ], (err, results) ->
    if err
      return done(err, null)      
    return done(null, results)

