_ = require('lodash')

exports.clearAllRooms = () ->
  # free room
  cond = 
    nahiRoom: false

  MathRoom.destroy cond, (err, mathrooms)->
    sails.log.info "destroy [#{mathrooms.length}] free mathroom..."
    if err
      return sails.log.info err

    roomIds = _.pluck(mathrooms, 'id')
    if roomIds[0]?
      Room.destroy id: roomIds
      RoomMember.destroy room: roomIds
      Chat.destroy room: roomIds

  # nahi room
  cond = 
    nahiRoom: true

  MathRoom.update cond, {status: MathRoom.STATUSES.OPENED}, (err, mathrooms)->
    sails.log.info "destroy [#{mathrooms.length}] nahi mathroom..."

  # clear all match, player, viewer
  MathRoomPlayer.destroy {}
  MathRoomViewer.destroy {}, (err, ss)->    
  MathRoomMatch.destroy {}
  MathRoomMatchPlayer.destroy {}


exports.detectRemoveDisableRooms = ()->
  timeNow = new Date()
  roomTimeout = 20

  # free room
  cond = 
    $or: [
      status: MathRoom.STATUSES.DISABLE
      nahiRoom: false
    ,
      status: 
        '!': MathRoom.STATUSES.LOCKED 
      updatedAt:
        '<': _.clone(timeNow).addMinutes(-roomTimeout)
      nahiRoom: false
    ]

  MathRoom.destroy cond, (err, mathrooms)->
    sails.log.info "destroy [#{mathrooms.length}] free mathroom..."
    if err
      sails.log.info err
      return

    roomIds = _.pluck(mathrooms, 'id')
    if roomIds[0]?
      Room.destroy id: roomIds
      RoomMember.destroy room: roomIds
      Chat.destroy room: roomIds

      MathRoomPlayer.destroy mathroom: roomIds
      MathRoomViewer.destroy mathroom: roomIds
      MathRoomMatch.destroy mathroom: roomIds, (err, mathroommatches) ->        
        mathroommatchIds = _.pluck(mathroommatches, 'id')
        if mathroommatchIds[0]?
          MathRoomMatchPlayer.destroy mathroommatch: mathroommatchIds

  
  # nahi room
  cond = 
    updatedAt:
      '<': _.clone(timeNow).addMinutes(-roomTimeout)
    nahiRoom: true

  MathRoom.update cond, {status: MathRoom.STATUSES.OPENED}, (err, mathrooms)->
    sails.log.info "destroy [#{mathrooms.length}] nahi mathroom..."
    if err
      sails.log.info err
      return
      
    roomIds = _.pluck(mathrooms, 'id')
    if roomIds[0]?
      MathRoomPlayer.destroy mathroom: roomIds
      MathRoomViewer.destroy mathroom: roomIds
      MathRoomMatch.destroy mathroom: roomIds, (err, mathroommatches) ->        
        mathroommatchIds = _.pluck(mathroommatches, 'id')
        if mathroommatchIds[0]?
          MathRoomMatchPlayer.destroy mathroommatch: mathroommatchIds
  
  # destroy math room match 
  cond = 
    endTime:
      '<': _.clone(timeNow).addMinutes(-2)
  MathRoomMatch.destroy cond, (err, mathroommatches) -> 
    sails.log.info "destroy [#{mathroommatches.length}] mathroom match..."       
    mathroommatchIds = _.pluck(mathroommatches, 'id')
    if mathroommatchIds[0]?
      MathRoomMatchPlayer.destroy mathroommatch: mathroommatchIds
  
  MathRoomMatchPlayer.destroy cond, (err, players) ->    
    sails.log.info "destroy [#{players.length}] mathroom match player..."


