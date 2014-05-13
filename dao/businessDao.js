var daoHelper = require('./daoHelper');

exports.insert = function(business, callback){
	daoHelper.sql('insert into business set ?', business, callback);
}


exports.queryBySourceId = function(sourceId, callback){
	daoHelper.sql('select * from business where sourceId = ?', [sourceId], callback);
}

exports.queryUrls = function(callback){
	daoHelper.sql('select * from tmpUrls where complete is null', null, callback);
}


exports.updateUrl = function(url, callback){
	daoHelper.sql('update tmpUrls set complete = 1 where id = ?', [url.id], callback);
}

exports.queryGeoLike = function(geoHash, callback){
	daoHelper.sql('select * from business where geohash like ?', [geoHash + '%'], callback);
}

exports.queryPriceNull = function(callback){
	daoHelper.sql('select * from business where price is null', null, callback);
}

exports.updateBusiness = function(business, callback){
    daoHelper.sql('update business set price = ?,tel=?,rating=?,taste=?,ambience=?,serving=? where id=?',[business.price, business.tel,business.rating,business,ambience,business.serving, business.id], callback);
}
