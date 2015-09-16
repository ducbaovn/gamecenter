
module.exports = 
  list: (req, resp) ->
    params =
      isActive: true
      sortBy: 'ordering'
      sortOrder: 'asc'
      limit: -1

    GameCategoryService.list params, (err, list) ->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)

      return resp.ok(list)

