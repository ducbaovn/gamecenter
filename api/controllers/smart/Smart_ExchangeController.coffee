module.exports =
  listItems: (req, resp)=>
    params = req.allParams()
    ExchangeService.listItems params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  listItemStore: (req, resp)=>
    params = req.allParams()
    ExchangeService.listItemStore params, (err, items) ->
      if err
        return resp.badRequest(err)
      return resp.ok(items)

  listCategory: (req, resp)=>
    params = req.allParams()
    StoresService.listCategory params, (err, categorys) ->
      if err
        return resp.badRequest(err)
      return resp.ok(categorys)