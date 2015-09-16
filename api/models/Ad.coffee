_ = require('lodash')


module.exports =

  attributes:
    banner:
      model: 'banner'
      required: true

    adcode:
      type: 'string'
      required: true

    name:
      type: 'string'

    imageUrl:
      type: 'string'

    audioUrl:
      type: 'string'

    link:
      type: 'string'

    # mili seconds
    timeout:
      type: 'integer'

    amination:
      type: 'string'

    startTime:
      type: 'datetime'

    endTime:
      type: 'datetime'

    # [0,1,2,3,4,5,6,7]
    daysInWeek:
      type: 'array'

    # [0,1,2]
    hoursInDay:
      type: 'array'
