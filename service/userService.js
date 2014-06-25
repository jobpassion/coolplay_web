var userDao = require(ROOT + 'dao/userDao');
var dictionary = require(ROOT + 'config/dictionary');
var crypto = require('crypto');
var redisHelper = require(ROOT + 'dao/redisHelper');

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
			redisHelper.redis(function(err, client) {
				client.set('user-token-' + user.loginName, user.accessToken);
			});
            userDao.insert(user);
            callback(user, true);
        }
    })
}

exports.login = function(user, callback){
	if(!user.loginName||!user.password){
		callback({errCode:2, msg:dictionary.errCode[2]}, false);
		return;
	}
    var loginName = user.loginName;
    userDao.queryByName(loginName, function(results){
        if(results&&results.length>0){
			if(user.password==results[0].password){
				user.accessToken = randomToken;
				redisHelper.redis(function(err, client) {
					client.set('user-token-' + user.loginName, user.accessToken);
				});
				callback(user, true);
			}else
				callback({errCode:4, msg:dictionary.errCode[4]}, false);
        }else{
			callback({errCode:3, msg:dictionary.errCode[3]}, false);
		}
    })
}
exports.thirdLogin = function(user, callback){
	if(!user.nickname){
		callback({errCode:2, msg:dictionary.errCode[2]}, false);
		return;
	}
    var loginName = user.loginName;
    userDao.queryByParams({thirdLogin:user.thirdLogin, openId:user.openId}, function(results){
        if(results&&results.length>0){
			callback(results[0], true);
        }else{
			userDao.insert(user);
			callback(user, true);
		}
    })
}

function randomToken(){
    return crypto.randomBytes(20).toString('hex'); 
}


exports.addUserAction = function(userAction, callback){
	userDao.insertUserAction(userAction, function(result, error){
		if(error){
			callback({errCode:5, msg:dictionary.errCode[5]});
		}else{
			callback(result);
		}
	});
}