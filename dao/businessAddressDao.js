var daoHelper = require('./daoHelper');

exports.insert = function(businessAddress, callback){
	daoHelper.sql('insert into businessAddress set ?', businessAddress, callback);
}
