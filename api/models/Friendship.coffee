 # Friendship.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
_ = require('lodash')

REQUESTER_STATUSES =
  REQUESTING:   "REQUESTING"
  CONNECTING:   "CONNECTING"
  IGNORING:   "IGNORING"
  HIDDEN:   "HIDDEN"
  REMOVED:   "REMOVED"

RECEIVER_STATUSES =
  PENDING: "PENDING"
  CONNECTING: "CONNECTING"
  IGNORING: "IGNORING"
  HIDDEN: "HIDDEN"
  REMOVED: "REMOVED"

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  REQUESTER_STATUSES: REQUESTER_STATUSES
  RECEIVER_STATUSES: RECEIVER_STATUSES
  attributes:
    requester: 
      model: 'user'
      required: true

    receiver:
      model: 'user'
      required: true

    requesterStatus:
      type: 'string'
      required: true
      enum: _.values(REQUESTER_STATUSES)

    receiverStatus:
      type: 'string'
      required: true
      enum: _.values(RECEIVER_STATUSES)


