module.exports =
  list: (req, resp) ->
    params = req.allParams()
    StoreCategoryService.listCategory params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(result)

  add: (req, resp) ->
    params = req.allParams()
    StoreCategoryService.addCategory params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(result)

  update: (req, resp) ->
    params = req.allParams()
    StoreCategoryService.updateCategory params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(result)

  remove: (req, resp) ->
    params = req.allParams()
    StoreCategoryService.removeCategory params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(result)