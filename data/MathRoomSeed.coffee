_ = require("lodash")
async = require('async')
ObjectId = require('mongodb').ObjectID

createMathRoomData = (done)->
  sails.log.info "RUN createMathRoomData..........................."
  
  
  data = [
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Sơ khai 1',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.EASY
      operator: '1000'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Sơ khai 2',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.EASY
      operator: '0100'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Sơ khai 3',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.EASY
      operator: '0010'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Sơ khai 4',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.EASY
      operator: '0001'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Thí luyện 1',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.MEDIUM
      operator: '1000'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Thí luyện 2',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.MEDIUM
      operator: '0100'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Thí luyện 3',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.MEDIUM
      operator: '0010'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Thí luyện 4',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.MEDIUM
      operator: '0001'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Đấu trường 1',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.HARD
      operator: '1000'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Đấu trường 2',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.HARD
      operator: '0100'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Đấu trường 3',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.HARD
      operator: '0010'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
    ,    
      status: MathRoom.STATUSES.OPENED
      owner: null
      name: 'NAHI-Đấu trường 4',
      hasPassword: false
      password: ''
      mode: MathRoom.MODES.HARD
      operator: '0001'
      minLevel: 1
      timeLimit: 120
      teamLimit: 2
      memberPerTeam: 1
      starPerMember: 0      
      nahiRoom: true
      viewers: []
      players: []
      winItems: [
          itemCode: 'ENS05'
          rank: 1
        ,
          itemCode: 'ENS03'
          rank: 2
      ]
  ]

  callback = (e, rooms)->
    _.each rooms, (room)->
      chatRoomData = 
        id: room.id
        kind: Room.KINDS.MATHROOM
        name: "#{room.name} - CHAT ROOM"        

      Room.create chatRoomData, (e, r)->
        if e 
          sails.log.error e 

  MathRoom.create(data).exec(callback)


exports.execute = (cb)=>
  sails.log.info "MathRoom SEED EXECUTING..........................."
  MathRoom.count {nahiRoom:true}, (e, cnt)->
    if e
      sails.log.info e
    if cnt == 0
      createMathRoomData(cb)

  return cb(null)
