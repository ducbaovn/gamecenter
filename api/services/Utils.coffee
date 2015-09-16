
module.exports = 
  toBoolean: (value)->
    if _.isBoolean(value)
      return value
    return (value == 'true')

  # random the index in objs (with factor)
  randomWithFactor: (objs) ->
    sum = 0;
    sum += obj.factor for obj in objs
    randFactor = sum * Math.random()
    i = 0
    delta = randFactor
    # find index in objs so (sum of factor from 0 to index) < randFactor < (sum of factor from 0 to index + 1)
    while delta > 0
      delta -= objs[i].factor
      i++
    return i - 1