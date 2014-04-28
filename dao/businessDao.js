var daoHelper = require('./daoHelper');

exports.insert = function(business, callback){
	daoHelper.sql('insert into business set ?', business, callback);
}
