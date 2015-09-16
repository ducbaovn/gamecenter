STATUSES =
  FOLLOWED: 'FOLLOW'
  MUTED: 'MUTE'
  BANNED: 'BANNED'

module.exports =
  STATUSES: STATUSES
  attributes:
    user:
      model: 'user'
      required: true

    room:
      model: 'room'
      required: true

    status:
      type: 'string'
      defaultsTo: 'FOLLOW'
    