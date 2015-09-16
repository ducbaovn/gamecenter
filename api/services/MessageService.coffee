
################## TOAN THAN TOC ####################
exports.Math = MathMessage = {}

MATH_MODE = 
  'EASY': 'Khá'
  'MEDIUM': 'Giỏi'
  'HARD': 'Xuất sắc'

MATH_OPERATORS = 
  '1000': '+'
  '1100': '+, -'
  '1010': '+, x'
  '1001': '+, :'
  '1110': '+, -, x'
  '1101': '+, -, :'
  '1011': '+, x, :'
  '1111': '+, -, x, :'
  '0100': '-'
  '0010': 'x'
  '0001': ':'
  '0110': '-, x'
  '0101': '-, :'
  '0011': 'x, :'
  '0111': '-, x, :'

MathMessage.getChallengeMessage = (challenge, user, done)=>  
  _replaceDataFields = (content)->
    return content.replace(/{nickname}/g, user.nickname)
                  .replace(/{math_mode}/g, MATH_MODE[challenge.score.extends.mode])
                  .replace(/{math_operator}/g, MATH_OPERATORS[challenge.score.extends.operator])
                  .replace(/{math_time}/g, challenge.score.time)
                  .replace(/{math_score}/g, challenge.score.score)

  result = 
    title: 'N/A'
    content: 'N/A'

  cond = 
    gameCode: challenge.gameCode
    category: NoteMessage.NOTIFY_CATEGORIES.CHALLENGE

  NotificationTemplateService.getActiveTemplate cond, (template)->
    if template 
      result = 
        title: _replaceDataFields(template.title)
        content: _replaceDataFields(template.content)

    done(result)

exports.Brain = BrainMessage = {}

MINIGAME =
  'DT01': 'Đúng nơi đúng chỗ'
  'DT02': 'Tìm bóng cho hình'
  'DT03': 'Nhanh mắt nhớ hình'
  'DT04': 'Phân biệt hình và chữ'
  'DT05': 'Siêu tính nhẩm'
  'DT06': 'Nhiều hơn hay ít hơn'
  'DT07': 'Tính nhanh nhớ giỏi'
  'DT08': 'Nhanh tay dọn món'

BrainMessage.getChallengeMessage = (challenge, user, done)=>  
  _replaceDataFields = (content)->
    return content.replace(/{nickname}/g, user.nickname)
                  .replace(/{brain_minigame}/g, MINIGAME[challenge.score.extends.minigame])
                  .replace(/{brain_time}/g, challenge.score.time)
                  .replace(/{brain_score}/g, challenge.score.score)

  result = 
    title: 'N/A'
    content: 'N/A'

  cond = 
    gameCode: challenge.gameCode
    category: NoteMessage.NOTIFY_CATEGORIES.CHALLENGE

  NotificationTemplateService.getActiveTemplate cond, (template)->
    if template 
      result = 
        title: _replaceDataFields(template.title)
        content: _replaceDataFields(template.content)

    done(result)
