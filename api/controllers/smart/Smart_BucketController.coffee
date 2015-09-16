module.exports =
  getMyBucket: (req, resp) ->
    params = req.allParams()
    BucketService.getMyBucket params, (err, result) ->
      if err
        return resp.badRequest(err)
      return resp.ok(result)

  # req: {x-user-token, gamecode, itemcode, quantity}
  addItemToBucket: (req, resp)->
    params = req.allParams()
    BucketService.addItemToBucket params, (err, bucket)->
      if err
        return resp.badRequest(err)
      return resp.ok(bucket)
        
  # req: {x-user-token, gamecode, itemcode}
  useItemOnBucket: (req, resp)->
    if !req.param('gameCode')
      return resp.status(400).send({code: 5067, error: 'missing game code'})

    Game.findOne code: req.param('gameCode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      req.game = game
      BucketService.useItemOnBucket(req, resp)

  # req: {x-user-token, gamecode, itemcode}
  getBucketItem: (req, resp)->
    if !req.param('gameCode')
      return resp.status(400).send({5067, error: 'missing game code'})

    Game.findOne code: req.param('gameCode'), (e, game)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      if !game
        return resp.status(400).send({code: 5033, error: 'not found game'})
      req.game = game
      BucketService.getBucketItem(req, resp)
