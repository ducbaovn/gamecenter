module.exports =

  attributes:
    sender:
      model: 'user'
      required: true

    room:
      model: 'room'
      required: true

    message:
      type: 'string'
      required: true

    spamsCount:
      type: 'integer'
      defaultsTo: 0