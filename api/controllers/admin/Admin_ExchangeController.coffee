module.exports =
  listItems: (req, resp)=>
    params = req.allParams()
    ExchangeService.listItems params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)
  addItems: (req, resp)=>
    params = req.allParams()
    ExchangeService.addItems params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  updateItems: (req, resp)=>
    params = req.allParams()
    ExchangeService.updateItems params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  removeItems: (req, resp)=>
    params = req.allParams()
    ExchangeService.removeItems params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)