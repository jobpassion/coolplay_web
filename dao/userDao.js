var daoHelper = require('./daoHelper');

exports.insert = function(user){
    daoHelper.sql('INSERT INTO user SET ?', user, function(result){});
}
exports.queryByname = function(name, callback){
	daoHelper.sql('select * from user where name=?', name, callback);
}
