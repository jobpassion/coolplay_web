util = require(ROOT + "util/util")
config = require(ROOT + "config/config")
exports.auth=(req,res,next)->
  if config.local
    req.session.userId = 2
    return next()
  if req.session and req.session.authorized
    next()
  else
    res.json util.error 6 

