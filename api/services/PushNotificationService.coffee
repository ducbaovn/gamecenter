exports.pushNote = (note, cb)->  
  GcmService.pushNote note, cb
  ApnService.pushNote note, cb