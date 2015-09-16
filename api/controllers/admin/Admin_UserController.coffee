# Admin User Controller
module.exports =
  list: (req, resp) ->
    params = req.allParams()

    # build sort condition
    if !params.sortBy || params.sortBy not in ['email', 'fullname', 'nickname']
      params.sortBy = 'createdAt'
    if !params.sortOrder || params.sortOrder not in ['asc', 'desc']
      params.sortOrder = 'desc'
    sortCond = {}
    sortCond[params.sortBy] = params.sortOrder

    # build condition   
    params.page = parseInt(params.page) || 1
    params.limit = parseInt(params.limit) || 10

    cond = {}

    if params.filter
      cond.or = [
        email:
          contains: params.filter
      ,
        nickname:
          contains: params.filter
      ]

    User.find cond
    .paginate {page: params.page, limit: params.limit}
    .sort(sortCond)
    .exec (e, users) ->
      if e
        sails.log.error e
        return resp.badRequest({code: 5000, error: e})

      User.count cond, (e, total) ->
        if e
          sails.log.error "could not count user list"
          return resp.badRequest({code: 5000, error: e})     
        return resp.ok(total: total, result: users)


  view: (req, resp) ->
    params = req.allParams()
    if !params.userid || params.userid.trim().length == 0
      return resp.badRequest({code: 5140, error: 'missing param userid or not valid'})

    User.findOne params.userid, (e, user) ->
      if e
        sails.log.error e
        return resp.badRequest({code: 5000, error: e})
      if !user
        return resp.badRequest({code: 5020, error: 'not found user'})

      return resp.ok(user)

  buckets: (req, res)->
    params = req.allParams()
    if !params.user? || !params.gameCode?
      return res.badRequest({code: 5128, error: 'missing required params (user, game)'})
    User.findOne id: params.user, (err, user)->
      if err
        return res.badRequest({code: 5000, error: err})
      if !user?
        return res.badRequest({code: 5148, error: 'User is not found'})
      params.user = user.publicJSON()
      BucketService.getMyBucket params, res
