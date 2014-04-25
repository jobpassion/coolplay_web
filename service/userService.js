var userDao = require(ROOT + 'dao/userDao');
var crypto = require('crypto');

exports.register = function(user, callback){
    var loginName = user.loginName;
    userDao.queryByName(loginName, function(results){
        if(results&&results.length>0){
            callback({errCode:1}, false);
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
