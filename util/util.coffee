dictionary = require(ROOT + "config/dictionary")
exports.resultHandle = (callback, errorCode) ->
  (result, error) ->
    if error
      callback
        errCode: errorCode
        msg: dictionary.errCode[errorCode]

    else
      callback result
    return
exports.error = (errCode) ->
	errCode:errCode
	msg:dictionary.errCode[errCode]
