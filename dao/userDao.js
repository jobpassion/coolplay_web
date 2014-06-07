var daoHelper = require('./daoHelper');

exports.insert = function(user, callback){
    daoHelper.sql('INSERT INTO user SET ?', user, callback);
}
exports.queryByName = function(name, callback){
    daoHelper.sql('select * from user where loginName = ?', [name], callback);
}
exports.queryByname = function(name, callback){
	daoHelper.sql('select * from user where name=?', name, callback);
}
exports.queryByParams = function(params, callback){
	var whereCause = '';
	for(var i in params){
		whereCause += ' and '+ i + "='" + params[i] + "'";
	}
	daoHelper.sql('select * from user where 1=1' + whereCause, null, callback);
}
