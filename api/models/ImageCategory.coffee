
 # ImageCategory.coffee
 
_ = require('lodash')
CATEGORY =
  DIRECTION: 'Bộ hướng'
  COLOR: 'Bộ màu'
  VEGETABLE_FOOD: 'Bộ rau, củ quả, trái cây'
  PIE: 'Bộ bánh'
  CANDY: 'Bộ kẹo'
  DRINK: 'Bộ nước uống'
  ANIMAL: 'Bộ động vật'
  VEGETABLE: 'Bộ thực vật'
  ALPHABET: 'Bộ chữ viết'
  NUMBER: 'Bộ số'
  BOY: 'Bộ bé trai'
  GIRL: 'Bộ bé gái'
  SHIRT: 'Bộ áo unisex'
  TROUSERS: 'Bộ quần unisex'
  MALE_SHIRT: 'Bộ áo nam'
  FEMALE_SHIRT: 'Bộ áo nữ'
  MALE_TROUSERS: 'Bộ quần nam'
  FEMALE_TROUSERS: 'Bộ quần nữ'
  SHAWLS: 'Bộ khăn choàng unisex'
  MALE_SHAWLS: 'Bộ khăn choàng nam'
  FEMALE_SHAWLS: 'Bộ khăn choàng nữ'
  GLASSES: 'Bộ mắt kính unisex'
  MALE_GLASSES: 'Bộ mắt kính nam'
  FEMALE_GLASSES: 'Bộ mắt kính nữ'
  HAT: 'Bộ nón'
  MALE_HAT: 'Bộ nón nam'
  FEMALE_HAT: 'Bộ nón nữ'
  SHOES: 'Bộ giày unisex'
  MALE_SHOES: 'Bộ giày nam' 
  FEMALE_SHOES: 'Bộ giày nữ'
  TIE: 'Bộ cà vạt'
  MALE_TIE: 'Bộ cà vạt nam'
  FEMALE_TIE: 'Bộ cà vạt nữ'
  BAG: 'Bộ cặp'
  MALE_BAG: 'Bộ cặp nam'
  FEMALE_BAG: 'Bộ cặp nữ'
  TYPE: 'Bộ phân loại'
  QUESTION: 'Bộ câu hỏi'

module.exports =
  CATEGORY: CATEGORY
  schema: true
  attributes:
    code:
      type: 'string'
      unique: true
      required: true

    name:
      type: 'string'
      required: true

    game:
      model: 'Game'     

    images:
      collection: 'Image'
      via: 'category'

    description:
      type: 'string'

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj
