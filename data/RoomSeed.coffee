createChatRoom = ()=>
  data = 
    kind: Room.KINDS.PUBLIC
    name: 'NAHI CHAT ROOM'  

  Room.findOne data, (e, room)->
    if e
      return false
    if !room
      Room.create data, (e, r)->
        sails.log.info e

    return true

exports.execute = (cb)=>
  sails.log.info "ROOM SEED EXECUTING..........................."
  createChatRoom()

  cb(true)