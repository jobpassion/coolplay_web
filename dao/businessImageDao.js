var daoHelper = require('./daoHelper');

exports.insert = function(businessImage, callback){
	daoHelper.sql('insert into businessImage set ?', businessImage, callback);
}
