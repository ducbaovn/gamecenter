'use strict'
ChatRoom.controller 'ChatRoomCtrl', [
  '$scope', 
  '$rootScope', 
  '$filter', 
  '$modal', 
  '$sails', 
  '$log', 
  'CurrentUser', 
  ($scope, $rootScope, $filter, $modal, $sails, $log, CurrentUser)->
    $scope.CurrentUser = CurrentUser
    $scope.flash =
      message: null
      shown: false
    $sails.on 'connect', ()=>
      $log.debug 'you are aaaaaa'

    $sails.on 'connected', ()=>
      $log.debug 'you are connected'

    $sails.on 'CHAT:AUTHORIZED', ()=>
      $log.debug 'CHAT: you are authorized'
      CurrentUser.socketId = $sails.socket.sessionid

      # setTimeout ()->
      #   console.log '$timeout'
      #   console.log CurrentUser
      # , 10000

    $sails.on 'CHAT:ROOM:USER:JOIN', (data)=>
      console.log 'CHAT:ROOM:USER:JOIN'
      console.log data
      room = findRoomById(data.room)
      room.onlines ||= []
      room.onlines.push data
      $scope.flash.message = "#{data.nickname} has been join"
      $scope.flash.shown = true
      setTimeout ()->
        $scope.flash.shown = false
      , 30000

    $sails.on 'CHAT:ROOM:USER:LEAVE', (data)=>
      console.log 'CHAT:ROOM:USER:LEAVE'
      console.log data
      room = findRoomById(data.room)
      room.onlines ||= []
      user = $filter('filter')(room.onlines, {id: data.id})[0]
      idx = room.onlines.indexOf(user)
      room.onlines.splice( idx, 1 )
      $scope.flash.message = "#{data.nickname} has been leave"
      $scope.flash.shown = true
      setTimeout ()->
        $scope.flash.shown = false
      , 30000

    $sails.on 'CHAT:ROOM:MESSAGE', (data)=>
      console.log 'CHAT:ROOM:MESSAGE'
      console.log data
      room = findRoomById(data.room)
      console.log room
      if room
        room.chat ||= []
        room.chat.push data
    
    $sails.on 'CHAT:PEER:MESSAGE', (data)=>
      console.log 'CHAT:PEER:MESSAGE'
      user = findPeerUserById(data.sender.id)
      if user
        user.chat ||= []
        user.chat.push data
      else
        sender = data.sender
        $sails.post "/chat/messages", {token: CurrentUser.token, userid: sender.id}, (msgs)->
          if msgs
            msgs = msgs.reverse()
            sender.chat = msgs
        CurrentUser.peerUsers.push sender
      
    $scope.join = (room)=>
      CurrentUser.joinRoom(room)

    $scope.leaveRoom = (room)=>
      console.log 'leave room'
      console.log room
      CurrentUser.leaveRoom(room)

    $scope.sendMessageRoom = (message, room)=>
      if !! message
        CurrentUser.sendMessageRoom(room, message)

    findRoomById = (roomId)=>
      rooms = $filter('filter')(CurrentUser.openRooms, {id: roomId})
      room = rooms[0]
      return room
    findPeerUserById = (userId)=>
      users = $filter('filter')(CurrentUser.peerUsers, {id: userId})
      usr = users[0]
      return usr

    $scope.peerChat = (user, message)=>
      CurrentUser.peerChat(user, message)

    $scope.openPeerChat = (user)=>
      idx = CurrentUser.peerUsers.indexOf(user)
      if idx < 0
        $sails.post "/chat/messages", {token: CurrentUser.token, userid: user.id}, (msgs)->
          if msgs
            msgs = msgs.reverse()
            user.chat = msgs
          console.log "CHAT/messages"
          console.log JSON.stringify(msgs)
        CurrentUser.peerUsers.push user

    # $scope.openModal = ()=>
    #   modalInstance = $modal.open 
    #     templateUrl: 'templates/test.html'
    #     controller: 'PrivateRoomCtrl'
    #     resolve:
    #       todo: ()->
    #         return true

    #   modalInstance.result.then (result)->
    #     todo = result.todo
    #     console.log todo
    
  ]
