module.exports =
  list: (req, resp)=>
    if !req.param('gameCode')
      return resp.status(400).send({code: 5067, error: 'missing gameCode'})

    Game.findOne code: req.param('gameCode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      ItemService.listItems(req, resp)

  listCombo: (req, resp) =>
    if !req.param('gameCode')
      return resp.status(400).send({code: 5067, error: 'missing gameCode'})

    Game.findOne code: req.param('gameCode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      ItemService.listCombo(req, resp)

  create: (req, resp)=>
    if !req.param('gameCode')
      return resp.status(400).send({code: 5067, error: 'missing game code'})

    Game.findOne code: req.param('gameCode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      ItemService.createItem(req, resp)

  update: (req, resp)=>
    ItemService.updateItem(req, resp)

  status: (req, resp)=>
    isActive = req.param('isActive')
    if !isActive?
      return resp.badRequest({code: 5108, error: 'missing param isActive'})

    if Utils.toBoolean(isActive)
      ItemService.enableItem(req, resp)
    else
      ItemService.disableItem(req, resp)

  get: (req, resp)=>
    ItemService.getItem(req, resp)
