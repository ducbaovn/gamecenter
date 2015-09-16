_ = require('lodash')

VISIBLE_APIS = 
  SMART_PLUS: 'SP01'
  STAR_GARDEN: 'SG01'
  DUEL: 'DUEL'
  MATH: 'TTT01'
  BRAIN: 'DAUTRI'
  DUNG_NOI: 'DT01'
  TIM_BONG: 'DT02'
  NHANH_MAT: 'DT03'
  PHAN_BIET: 'DT04'
  TINH_NHAM: 'DT05'
  NHIEU_IT: 'DT06'
  TINH_NHANH: 'DT07'
  NHANH_TAY: 'DT08'

BRAIN_MINIGAMECODE =
  DUNG_NOI: 'DT01'
  TIM_BONG: 'DT02'
  NHANH_MAT: 'DT03'
  PHAN_BIET: 'DT04'
  TINH_NHAM: 'DT05'
  NHIEU_IT: 'DT06'
  TINH_NHANH: 'DT07'
  NHANH_TAY: 'DT08'

BRAIN_MINIGAME =
  DUNG_NOI: 'Đúng nơi đúng chỗ'
  TIM_BONG: 'Tìm bóng cho hình'
  NHANH_MAT: 'Nhanh mắt nhớ hình'
  PHAN_BIET: 'Phân biệt hình và chữ'
  TINH_NHAM: 'Siêu tính nhẩm'
  NHIEU_IT: 'Nhiều hơn hay ít hơn'
  TINH_NHANH: 'Tính nhanh nhớ giỏi'
  NHANH_TAY: 'Nhanh tay dọn món'
  
module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  VISIBLE_APIS: VISIBLE_APIS
  BRAIN_MINIGAME: BRAIN_MINIGAME
  BRAIN_MINIGAMECODE: BRAIN_MINIGAMECODE
  attributes:
    category:
      model: 'GameCategory'

    code:
      type: 'string'
      index: true
      unique: true
      required: true
      
    name:
      type: 'string'
      required: true
      size: 200
      unique: true

    description:
      type: 'string'

    icon:
      type: 'string'
      required: true

    cover:
      type: 'string'

    # {
    #   ios: '',
    #   android: ''
    # }
    packageUrl:
      type: 'json'

    # {
    #   ios: '',
    #   android: ''
    # }
    packageId:
      type: 'json'  

    # array of parent's game code
    parent:
      type: 'array'
      defaultsTo: []

    ordering: 
      type: 'integer'
      defaultsTo: 1

    isActive:
      type: 'boolean'
      required: true
      defaultsTo: true
    
    naturalExpPreset:
      type: 'float'
      defaultsTo: 0.0

    socialExpPreset:
      type: 'float'
      defaultsTo: 0.0   

    langExpPreset:
      type: 'float'
      defaultsTo: 0.0

    # number of time game have played
    playsCount:
      type: 'integer'
      defaultsTo: 0

    # vat pham la tien con cua game
    moneyItem: 
      model: 'item'

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.playsCount
      obj      
    