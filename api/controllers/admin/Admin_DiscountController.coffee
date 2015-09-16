module.exports =
  list: (req, resp)=>
    params = req.allParams()
    DiscountService.list params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  add: (req, resp)=>
    params = req.allParams()
    DiscountService.add params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  update: (req, resp)=>
    params = req.allParams()
    DiscountService.update params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  remove: (req, resp)=>
    params = req.allParams()
    DiscountService.remove params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)