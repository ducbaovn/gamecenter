_ = require('lodash')

exports.detectRemoveExpiredNoteMessages = ()->
  timeNow = new Date()
  cond = 
    $or: [
      { expiredTime: '<=': timeNow }
      { userStatus: NoteMessage.USER_STATUSES.CLOSE }
    ]

  NoteMessage.destroy cond, (e, r)->
    sails.log.info "remove note messages: #{JSON.stringify(r)}"