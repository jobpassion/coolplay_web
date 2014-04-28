var daoHelper = require('./daoHelper');

exports.insert = function(businessReview, callback){
	daoHelper.sql('insert into businessReview set ?', businessReview, callback);
}
