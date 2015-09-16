exports.resetEnergy = () =>
  ConfigurationService.getCommonConfig (err, config) ->
    if !err
      User.update {}, {energy: config.energyPerDay}, (e,x) ->
        sails.log.info "Updated energy for [#{x.length}] users"