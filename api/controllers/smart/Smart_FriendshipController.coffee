 # FriendshipController
 #
 # @description :: Server-side logic for managing friendships
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports =
  addFriend: (req, resp)=>
    FriendService.addFriend req, (e, data)->
      sails.log.info e
      sails.log.info data
      if e
        resp.status(400).send(error: e)
        return
      sails.log.info e
      sails.log.info data
      resp.send(success: data)

  acceptFriend: (req, resp)=>
    FriendService.acceptFriend req, (e, data)->
      sails.log.info e
      sails.log.info data
      if e
        resp.status(400).send(error: e)
        return
      sails.log.info e
      sails.log.info data
      resp.send(success: data)

  listFriend: (req, resp)=>
    