var userDao = require(ROOT + 'dao/userDao');
var dictionary = require(ROOT + 'config/dictionary');
var crypto = require('crypto');

exports.register = function(user, callback){
	
	if(!user.loginName||!user.password){
		callback({errCode:2, msg:dictionary.errCode[2]}, false);
		return;
	}
    var loginName = user.loginName;
    userDao.queryByName(loginName, function(results){
        if(results&&results.length>0){
            callback({errCode:1, msg:dictionary.errCode[1]}, false);
        }else{
            user.accessToken = randomToken();
            userDao.insert(user);
            callback(user, true);
        }
    })
}


function randomToken(){
    return crypto.randomBytes(20).toString('hex'); 
}
