 # GameController
 #
 # @description :: Server-side logic for managing games
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports = 
  list: (req, resp)->
    params = {}
    params.page = req.param('page')
    params.limit = req.param('limit')
    params.category = req.param('category')
    params.isActive = true
    params.parent = Game.VISIBLE_APIS.SMART_PLUS
    
    GameService.list params, (err, list)->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)
      return resp.ok(list)


  brainList: (req, resp)->
    params = {}  
    params.page = req.param('page')
    params.limit = req.param('limit')
    params.isActive = true
    params.parent = Game.VISIBLE_APIS.BRAIN

    GameService.list params, (err, list)->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)
      return resp.ok(list)


  duelList: (req, resp)->
    params = {}
    params.page = req.param('page')
    params.limit = req.param('limit')
    params.isActive = true
    params.parent = Game.VISIBLE_APIS.DUEL

    GameService.list params, (err, list)->
      if err
        sails.log.info err.log
        return resp.badRequest(code: err.code, error: err.error)
      return resp.ok(list)
