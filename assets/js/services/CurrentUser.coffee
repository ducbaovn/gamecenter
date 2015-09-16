'use strict'
ChatRoom.factory 'CurrentUser', [
  '$sails', 
  '$log', 
  ($sails, $log)->
    token: null
    fullname: null
    nickname: null
    authorized: false
    id: null
    openRooms: []
    rooms: []
    roomsLoaded: false
    users: []
    usersLoaded: false
    socketId: null
    peerUsers: []

    fetchRooms: (force=false)->
      console.log '$sails'
      console.log this
      _that = this
      return false if _that.roomsLoaded && !force

      $sails.post '/chat/rooms', (data)->
        console.log "LOAD ROOOMS"
        console.log JSON.stringify(data)
        _that.roomsLoaded = true
        _that.rooms = data

    fetchUsers: (force=false)->
      that = this 
      return false if that.usersLoaded && !force
      $sails.post '/chat/onlines', (data)->
        console.log "ONLINE USERS"
        console.log JSON.stringify(data)
        that.usersLoaded = true
        that.users = data


    auth: ()->
      that = this
      return true if that.authorized
      $sails.post '/chat/auth', {token: that.token}, (data)->
        console.log "USERS: AUTHORIZE"
        console.log JSON.stringify(data)
        that.authorized = data.id?
        that.fullname = data.fullname
        that.nickname = data.nickname
        that.avatar_url = data.avatar_url
        that.dob = data.dob
        that.id = data.id
        that.fetchRooms(true)
        that.fetchUsers(true)

    joinRoom: (room)->
      that = this
      $sails.post "/room/#{room.id}/join", {token: that.token}, (data)->
        console.log "ROOM: JOIN"
        console.log JSON.stringify(data)      
        if data
          room.onlines ||= []
          $sails.post "/room/#{room.id}/onlines", {token: that.token}, (usrs)->
            console.log "ROOM: USER ONLINE"
            console.log JSON.stringify(usrs)
            if usrs
              room.onlines = usrs
          room.chat ||= []
          $sails.post "/room/#{room.id}/messages", {token: that.token}, (msgs)->
            console.log "ROOM: MESSAGES"
            console.log JSON.stringify(msgs)
            if msgs
              room.chat = msgs.reverse()

          that.openRooms.push room

    leaveRoom: (room)->
      that = this
      $sails.post "/room/#{room.id}/leave", {token: that.token}, (data)->
        if data
          idx = that.openRooms.indexOf(room)
          that.openRooms.splice( idx, 1 )
          console.log that.openRooms

    sendMessageRoom: (room, message)->
      that = this
      $sails.post "/room/#{room.id}/chat", {token: that.token, message: message}, (data)->
        console.log 'post callback'
        console.log data
        if data
          room.chat ||= []
          room.chat.push data
          console.log room

    peerChat: (user, message)->
      that = this
      $sails.post "/chat/private", {message: message, userid: user.id, token: that.token}, (data)->
        console.log JSON.stringify(data)    
        user.chat ||= []
        user.chat.push data
  ]
  