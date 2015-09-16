
module.exports =
  gcTransferStarsToFriend: (req, resp)->
    DonationService.gcTransferStarsToFriend req, (e, isValid)->
      if e
        return resp.status(400).send(e)
      if !isValid
        return resp.status(400).send({code: 5104, error: 'Không thực hiện được chuyển gạo cho người nhận'})
      return resp.status(200).send(success: 'ok')

  webTransferStarsToFriend: (req, resp)->
    DonationService.webTransferStarsToFriend req, (e, isValid)->
      if e
        return resp.status(400).send(e)
      if !isValid
        return resp.status(400).send({code: 5104, error: 'Không thực hiện được chuyển gạo cho người nhận'})
      return resp.status(200).send(success: 'ok')
