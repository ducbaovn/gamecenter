module.exports =
  getEnergy: (req, resp)->
    resp.status(200).send(energy: req.user.energy)


  addEnergy: (req, resp)->
    user = req.user
    user.energy = parseInt(req.param('energy')) + user.energy
    User.update {id: user.id}, {energy: user.energy}, (e, usr)->
      if e
        return resp.status(400).send({code: 5000, error: e})
      resp.status(200).send(success: 'ok')

  useEnergy: (req, resp)->
    user = req.user
    if user.energy < parseInt(req.param('energy'))
      return resp.status(400).send({code: 5078, error: 'Số energy không hợp lệ.'})

    user.energy -= parseInt(req.param('energy'))
    if user.energy < 0
      user.energy = 0
    User.update {id: user.id}, {energy: user.energy}, (e, usr)->
      if e
        return resp.status(400).send({code: 5000, error: e})

      return resp.status(200).send(success: 'ok')
