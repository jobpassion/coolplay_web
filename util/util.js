var dictionary = require(ROOT + 'config/dictionary');

exports.resultHandle = function (callback, errorCode){
	return function (result, error){
		if(error){
			callback({errCode:errorCode, msg:dictionary.errCode[errorCode]});
		}else{
			callback(result);
		}
	}
}