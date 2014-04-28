var daoHelper = require('./daoHelper');

exports.insert = function(businessPromotion, callback){
	daoHelper.sql('insert into businessPromotion set ?', businessPromotion, callback);
}
