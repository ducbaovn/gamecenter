module.exports =
  receive: (req, resp)=>
    Game.findOne code: Game.VISIBLE_APIS.MATH, (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if ! game?
        return resp.status(400).send({code: 5033, error: 'not found math game'})
      req.game = game
      MathItemService.receiveItems(req, resp)

  useOne: (req, resp)=>
    Game.findOne code: Game.VISIBLE_APIS.MATH, (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if ! game?
        return resp.status(400).send({code: 5033, error: 'not found math game'})
      req.game = game
      req.itemid = req.param('itemid')
      MathItemService.useSingleItem(req, resp)

  showCode: (req, resp)=>
    RealItemService.showCode(req, resp)

  combinePartialItem: (req, resp)=>
    Game.findOne code: Game.VISIBLE_APIS.MATH, (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if! game?
        return resp.status(400).send({code: 5033, error: 'not found math game'})
      req.game = game
      req.itemid = req.param('itemid')
      MathItemService.combineItems(req, resp)

  myItems: (req, resp)=>
    Game.findOne code: Game.VISIBLE_APIS.MATH, (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if ! game?
        return resp.status(400).send({code: 5033, error: 'not found math game'})
      req.game = game
      MathItemService.myItems(req, resp)