module.exports =
  listItems: (req, resp)=>
    if !req.param('gamecode')
      return resp.status(400).send({code: 5067, error: 'missing game code'})

    Game.findOne code: req.param('gamecode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      req.game = game
      ItemService.listItems(req, resp)

  createItem: (req, resp)=>
    if !req.param('gamecode')
      return resp.status(400).send({code: 5067, error: 'missing game code'})

    Game.findOne code: req.param('gamecode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      req.game = game
      ItemService.createItem(req, resp)

  updateItem: (req, resp)=>
    ItemService.updateItem(req, resp)

  enableItem: (req, resp)=>
    ItemService.enableItem(req, resp)

  disableItem: (req, resp)=>
    ItemService.disableItem(req, resp)

  getItem: (req, resp)=>
    ItemService.getItem(req, resp)
