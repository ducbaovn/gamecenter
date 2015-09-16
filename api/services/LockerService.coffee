lockerList = {}

module.exports = 
  lock: (key) ->
    lockerList[key] = 1

  unlock: (key) ->
    delete lockerList[key]

  isLocked: (key) ->
    return lockerList[key]?
