# *
# Level.js
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/#!documentation/models
# 
DEFAULT_LEVELS = [
  {name: 1, exp: 0},
  {name: 2, exp: 700},
  {name: 3, exp: 1900},
  {name: 4, exp: 3700},
  {name: 5, exp: 6100},
  {name: 6, exp: 9100},
  {name: 7, exp: 12700},
  {name: 8, exp: 16900},
  {name: 9, exp: 21700},
  {name: 10, exp:  27100},
  {name: 11, exp:  33100},
  {name: 12, exp:  39700},
  {name: 13, exp:  46900},
  {name: 14, exp:  54700},
  {name: 15, exp:  63100},
  {name: 16, exp:  72100},
  {name: 17, exp:  81700},
  {name: 18, exp:  91900},
  {name: 19, exp:  102700},
  {name: 20, exp:  114100},
  {name: 21, exp:  126100},
  {name: 22, exp:  138700},
  {name: 23, exp:  151900},
  {name: 24, exp:  165700},
  {name: 25, exp:  180100},
  {name: 26, exp:  195100},
  {name: 27, exp:  210700},
  {name: 28, exp:  226900},
  {name: 29, exp:  243700},
  {name: 30, exp:  261100},
  {name: 31, exp:  279100},
  {name: 32, exp:  297700},
  {name: 33, exp:  316900},
  {name: 34, exp:  336700},
  {name: 35, exp:  357100},
  {name: 36, exp:  378100},
  {name: 37, exp:  399700},
  {name: 38, exp:  421900},
  {name: 39, exp:  444700},
  {name: 40, exp:  468100},
  {name: 41, exp:  492100},
  {name: 42, exp:  516700},
  {name: 43, exp:  541900},
  {name: 44, exp:  567700},
  {name: 45, exp:  594100},
  {name: 46, exp:  621100},
  {name: 47, exp:  648700},
  {name: 48, exp:  676900},
  {name: 49, exp:  705700},
  {name: 50, exp:  735100},
  {name: 51, exp:  765100},
  {name: 52, exp:  795700},
  {name: 53, exp:  826900},
  {name: 54, exp:  858700},
  {name: 55, exp:  891100},
  {name: 56, exp:  924100},
  {name: 57, exp:  957700},
  {name: 58, exp:  991900},
  {name: 59, exp:  1026700},
  {name: 60, exp:  1062100},
  {name: 61, exp:  1098100},
  {name: 62, exp:  1134700},
  {name: 63, exp:  1171900},
  {name: 64, exp:  1209700},
  {name: 65, exp:  1248100},
  {name: 66, exp:  1287100},
  {name: 67, exp:  1326700},
  {name: 68, exp:  1366900},
  {name: 69, exp:  1407700},
  {name: 70, exp:  1449100},
  {name: 71, exp:  1491100},
  {name: 72, exp:  1533700},
  {name: 73, exp:  1576900},
  {name: 74, exp:  1620700},
  {name: 75, exp:  1665100},
  {name: 76, exp:  1710100},
  {name: 77, exp:  1755700},
  {name: 78, exp:  1801900},
  {name: 79, exp:  1848700},
  {name: 80, exp:  1896100},
  {name: 81, exp:  1944100},
  {name: 82, exp:  1992700},
  {name: 83, exp:  2041900},
  {name: 84, exp:  2091700},
  {name: 85, exp:  2142100},
  {name: 86, exp:  2193100},
  {name: 87, exp:  2244700},
  {name: 88, exp:  2296900},
  {name: 89, exp:  2349700},
  {name: 90, exp:  2403100},
  {name: 91, exp:  2457100},
  {name: 92, exp:  2511700},
  {name: 93, exp:  2566900},
  {name: 94, exp:  2622700},
  {name: 95, exp:  2679100},
  {name: 96, exp:  2736100},
  {name: 97, exp:  2793700},
  {name: 98, exp:  2851900},
  {name: 99, exp:  2910700},
  {name: 100, exp: 50000000}
]

TYPE =
  USER_LEVEL : 1
  SKILL_LEVEL : 2

module.exports =
  DEFAULT_LEVELS: DEFAULT_LEVELS
  TYPE: TYPE
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true

  attributes: 
    name:
      type: 'integer'
      required: true  

    exp:
      type: 'integer'
      required: true
      index: true

    type:
      type: 'integer'
      defaultsTo: 1

    desc:
      type: 'string'
