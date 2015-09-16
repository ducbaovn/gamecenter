
 # Image.coffee
 
_ = require('lodash')

IMAGE_VERSION_KEY = 'version:images'

updateImageVersion = (image, done) ->
  RedisService.incr IMAGE_VERSION_KEY, (err, version) ->
    if !err
      image.version = version
    done()

module.exports =
  IMAGE_VERSION_KEY: IMAGE_VERSION_KEY
  schema: true
  attributes:
    name:
      type: 'string'

    imageUrl:
      type: 'string'
      required: true 
      
    category:
      model: 'ImageCategory'
      via: 'images'

    version:
      type: 'integer'

    extends:
      type: 'JSON'

    toJSON: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      obj

    toTerm: ()->
      obj = this.toObject()
      delete obj.updatedAt
      delete obj.createdAt
      delete obj.category
      delete obj.imageUrl
      delete obj.version
      obj

  # Lifecycle Callbacks
  beforeCreate: (value, next) ->
    updateImageVersion(value, next)

  beforeUpdate: (value, next) ->
    updateImageVersion(value, next)