util = require(ROOT + "util/util")
exports.auth=(req,res,next)->
	if req.session and req.session.authorized
		next()
	else
		res.json util.error 6 

