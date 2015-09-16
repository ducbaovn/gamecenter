 # AdminUser.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

bcrypt = require('bcrypt')

hashPassword = (password, next)=>
  bcrypt.hash password, 10, (err, hash)->
    if (err)
      return next(err, null)
    next(null, hash)


module.exports =
  schema: true
  attributes:
    name:
      type: 'string'
      
    email:
      type: 'email'
      required: true
      unique: true

    password:
      type: 'string'
      required: true
      minLength: 6

    isActive:
      type: 'boolean'
      defaultsTo: true

    role:
      model: 'role'
      required: true

    toJSON: ()->
      obj = this.toObject()
      delete obj.password
      delete obj.createdAt
      delete obj.updatedAt
      return obj

    validPassword: (password, callback)->
      obj = this.toObject()
      if (callback)
        return bcrypt.compare(password, obj.password, callback)

      return bcrypt.compareSync(password, obj.password)

  # Lifecycle Callbacks
  beforeCreate: (values, next)->
    hashPassword values.password, (e, hash)->
      if (e)
        next(e)
      else
        values.password = hash
        next()

  beforeUpdate: (values, next)->
    if values.newPassword
      hashPassword values.newPassword, (e, hash)->
        if (e)
          next(e)
        else
          values.password = hash
          next()
    else 
      next()
