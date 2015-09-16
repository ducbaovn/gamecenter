_ = require('lodash')

OP_ENABLE = '1'
OPERATORS = 
  PLUS: '+'
  SUB: '-'
  MULT: '*'
  DIV: '/'

getOperator = (opConf)->
  operators = []
  if opConf[0] == OP_ENABLE
    operators.push OPERATORS.PLUS
  if opConf[1] == OP_ENABLE
    operators.push OPERATORS.SUB
  if opConf[2] == OP_ENABLE
    operators.push OPERATORS.MULT
  if opConf[3] == OP_ENABLE
    operators.push OPERATORS.DIV

  operator = _.sample(operators)
  return operator

getValue = (minValue, maxValue)->
  numbers = []
  i = minValue
  while i <= maxValue
    numbers.push i
    i++

  _.sample(numbers)

getArgs = (minA, maxA, minB, maxB, operator)->
  args = 
    aValue: minA
    bValue: minB

  if operator == OPERATORS.DIV && minB == 0
    minB = 1

  if operator != OPERATORS.DIV
    args.aValue = getValue(minA, maxA)
    args.bValue = getValue(minB, maxB)
    return args

  a = getValue(minA, maxA)
  b = getValue(minB, _.min([a, maxB]))
  while a%b != 0
    a = getValue(minA, maxA)
    b = getValue(minB, _.min([a, maxB]))

  args.aValue = a
  args.bValue = b
  return args

getResults = (aValue, bValue, operator)->
  results = 
    result: 0
    result_1: 0
    result_2: 0
  switch operator
    when OPERATORS.PLUS
      results.result = aValue + bValue
      break
    when OPERATORS.SUB
      results.result = aValue - bValue
      break
    when OPERATORS.MULT
      results.result = aValue * bValue
      break
    when OPERATORS.DIV
      results.result = aValue/bValue
      break

  minR = results.result - 5
  maxR = results.result + 5
  i = minR
  numbers = []
  while i <= maxR
    if i != results.result
      numbers.push i
    i++

  values = _.sample(numbers, 2)

  results.result_1 = values[0]
  results.result_2 = values[1]

  return results

getQuestion = (room)->
  operator = getOperator(room.operator)

  mode = room.mode
  MIN_VALUE_A = 0
  MAX_VALUE_A = 9
  MIN_VALUE_B = 0
  MAX_VALUE_B = 9
  switch mode
    when MathRoom.MODES.EASY
      MIN_VALUE_A = 0
      MAX_VALUE_A = 9
      MIN_VALUE_B = 0
      MAX_VALUE_B = 9
      break
    when MathRoom.MODES.MEDIUM
      MIN_VALUE_A = 10
      MAX_VALUE_A = 99
      MIN_VALUE_B = 10
      MAX_VALUE_B = 99
      break
    when MathRoom.MODES.HARD
      MIN_VALUE_A = 100
      MAX_VALUE_A = 999
      MIN_VALUE_B = 10
      MAX_VALUE_B = 99
      break

  terms = 
    operator: operator
  
  args = getArgs(MIN_VALUE_A, MAX_VALUE_A, MIN_VALUE_B, MAX_VALUE_B, operator)  
  terms.aValue = args.aValue
  terms.bValue = args.bValue

  results = getResults(terms.aValue, terms.bValue, terms.operator)

  terms.result = results.result
  terms.result_1 = results.result_1
  terms.result_2 = results.result_2

  return terms


exports.getTerms = (room, numQuestions=10)->
  terms = []
  i = 0
  while i < numQuestions
    terms.push getQuestion(room)
    i++

  return terms




