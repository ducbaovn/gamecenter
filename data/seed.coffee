cluster = require('cluster')
numCPUs = require('os').cpus().length
async = require('async')
_ = require('lodash')
GameSeed = require('./GameSeed')
ItemSeed = require('./ItemSeed')
LevelSeed = require('./LevelSeed')
RoomSeed = require('./RoomSeed')
MathRoomSeed = require('./MathRoomSeed')
ConfigurationSeed = require('./ConfigurationSeed')
AdminUser_Role_PermissionSeed = require('./AdminUser_Role_PermissionSeed')
MiniGame_ImageCategorySeed = require('./MiniGame_ImageCategorySeed')

exports.import = (cb)->
  if cluster.isMaster
    sails.log.info "isMaster"
  async.parallel [
    GameSeed.execute,
    LevelSeed.execute,
    RoomSeed.execute,
    MathRoomSeed.execute,
    ConfigurationSeed.execute,
    AdminUser_Role_PermissionSeed.execute
    MiniGame_ImageCategorySeed.execute
  ], (e, rst)->
    # ItemSeed.execute (e)->
    #   sails.log.info e

  cb()