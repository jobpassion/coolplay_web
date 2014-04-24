var daoHelper = require('./daoHelper');

exports.insert = function(user){
    daoHelper.sql('INSERT INTO user SET ?', user, function(result){});
}
