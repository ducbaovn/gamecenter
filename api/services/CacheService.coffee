LRU = require("lru-cache")

# # need improve
# caching for web
exports.webCache = LRU({max: 500})

# caching for mobile
exports.mobileCache = LRU({max: 1000})