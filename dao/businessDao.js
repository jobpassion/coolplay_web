var daoHelper = require('./daoHelper');

exports.insert = function(business, callback){
	daoHelper.sql('insert into business set ?', business, callback);
}


exports.queryBySourceId = function(sourceId, callback){
	daoHelper.sql('select * from business where sourceId = ?', [sourceId], callback);
}

exports.queryUrls = function(callback){
	daoHelper.sql('select * from tmpUrls where complete != 1', callback);
}


exports.updateUrl = function(url, callback){
	daoHelper.sql('update tmpUrls set complete = 1 where id = :id', url, callback);
}
