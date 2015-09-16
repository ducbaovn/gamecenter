async = require('async')

addToWeb = (req, webid, cb)=>
  WebService.addFriend req.user.token, webid, cb

addToLocal = (req, userid, cb)=>
  data =
    requester: req.user.id
    receiver: userid
    requesterStatus: Friendship.REQUESTER_STATUSES.REQUESTING
    receiverStatus: Friendship.RECEIVER_STATUSES.PENDING
  cod = 
    or: [
      requester: data.requester
      receiver: data.receiver
    ,
      requester: data.receiver
      receiver: data.requester
    ]
  Friendship.findOne cod, (e, friend)->
    if e
      return cb(e, null)
    if ! friend?
      Friendship.create data, (e, fs)->
        sails.log.info fs
      return cb(null, null)
    attrs = {}

    if data.requester == friend.requester && friend.requesterStatus != Friendship.REQUESTER_STATUSES.REQUESTING
      attrs.requesterStatus = Friendship.REQUESTER_STATUSES.CONNECTING

    if data.requester == friend.receiver
      attrs.requesterStatus = Friendship.RECEIVER_STATUSES.CONNECTING

    
    if _.values(attrs).length == 0
      return cb(null, null)
    Friendship.update friend.id, attrs, (e, f)->
      return cb(null, f)

exports.addFriend = (req, done)=>
  owner = req.user
  User.findOne req.param('friendid'), (e, user)->
    if e
      sails.log.info e
      return done(e, null)
    if ! user?
      sails.log.info 'not found user'
      return done('not found user', null)

    cb = (e, u)->


    addToWeb(req, user.webId, cb)
    addToLocal(req, user.id, cb)
    done(null, "ok")


exports.acceptFriend = (req, done)=>
  friendid = req.param('friendid')
  Friendship.findOne {requester: friendid}, (e, friend)->
    if e
      return done(e, null)
    if ! friend?
      return done('not found requester', null)

    friend.requesterStatus = Friendship.REQUESTER_STATUSES.CONNECTING
    friend.receiverStatus = Friendship.RECEIVER_STATUSES.CONNECTING

    friend.save()
    return done(null, 'ok')
    