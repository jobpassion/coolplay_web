var daoHelper = require('./daoHelper');

exports.insert = function(user, callback){
    daoHelper.sql('INSERT INTO user SET ?', user, callback);
}
exports.queryByName = function(name, callback){
    daoHelper.sql('select * from user where loginName = ?', [name], callback);
}
