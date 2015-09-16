#Admin game Nhanh Mat Bat Hinh Quiz Controller
module.exports = 

  list: (req, res) ->
    params = req.allParams()
    Admin_NhanhMatBatHinhQuizService.list params, (err, result) ->
      if err
        return res.badRequest(err)
      return res.ok(result)
    
  add: (req, res) ->
    params = req.allParams()

    if params.startDate && !(new Date(params.startDate)).getDate()
      return res.badRequest({code: 6046, error: 'Param startdate is not datetime type'})
    if params.endDate && !(new Date(params.endDate)).getDate()
      return res.badRequest({code: 6047, error: 'Param enddate is not datetime type'})
    if !params.question
      return res.badRequest({code: 6049, error: 'Missing param question'})
    if !params.answers
      return res.badRequest({code: 6050, error: 'Missing param answers'})
    Admin_NhanhMatBatHinhQuizService.add params, (err, result) ->
      if err
        return res.badRequest(err)
      return res.ok(result)


  update: (req, res) ->
    params = req.allParams()

    if !params.id
      return res.badRequest({code: 6048, error: 'Missing param id'})

    Admin_NhanhMatBatHinhQuizService.update params, (err, result) ->
      if err
        return res.badRequest(err)
      return res.ok(result)
    
  
  remove: (req, res) ->
    params = req.allParams()
    if !params.id
      return res.badRequest({code: 6048, error: 'Missing param id'})

    Admin_NhanhMatBatHinhQuizService.remove params, (err, result) ->
      if err
        return res.badRequest(err)
      return res.ok(success: 'ok')
  
  active: (req, res) ->
    params = req.allParams()
    if !params.id
      return res.badRequest({code: 6048, error: 'Missing param id'})
    if !params.isActive?
      return res.badRequest({code: 6051, error: 'Missing param isActive'})

    Admin_NhanhMatBatHinhService.active params, (err, result) ->
      if err
        return res.badRequest(err)
      return res.ok(success: 'ok')
    