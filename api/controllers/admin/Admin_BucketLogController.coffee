# Admin Bucket Log
module.exports =

  list: (req, res) ->
    params = req.allParams()
    Admin_BucketLogService.list params, (err, bucketsLog) ->
      if err
        console.log err
        res.badRequest(err)
      else
        res.status(200).send(bucketsLog)