 # NotificationController
 #
 # @description :: Server-side logic for managing notifications
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports =
  # req : {gamecode=*, category=*}
  listNotification: (req, resp)=>   
    params = req.allParams()      
    params.user = req.user

    NotificationService.listNotification params, (e, notes)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(notes)
  
  # req : {gamecode=*, title=*, content=*, category=*, days=5}
  createNotification: (req, resp)=>      
    params = req.allParams()      
    params.user = req.user

    NotificationService.createNotification params, (e, note)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(success: 'ok')

  # req : {id=*}
  readNotification: (req, resp)=>
    params = req.allParams()      
    params.user = req.user

    NotificationService.readNotification params, (e, note)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(success: 'ok')

  # req : {id=*}
  removeNotification: (req, resp)=>
    params = req.allParams()      
    params.user = req.user

    NotificationService.removeNotification params, (e, note)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(success: 'ok')

  getConfigList: (req, resp)=>  
    params = req.allParams()      
    params.user = req.user

    NotificationService.getConfigList params, (e, configs)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(configs)

  setConfig: (req, resp)=>
    params = req.allParams()  
    params.user = req.user

    NotificationService.setConfig params, (e, config)->
      if e
        return resp.status(400).send(e)
      return resp.status(200).send(success: 'ok')
