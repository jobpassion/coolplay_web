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
	var likeStr = '';
	for(var i in geoHash){
		likeStr += " or t1.geohash like '" + geoHash[i] + "%'";
	}
	likeStr = likeStr.substr(4);
	//daoHelper.sql('select * from business where ' + likeStr, null, callback);
	daoHelper.sql('select t1.*, count(t2.businessId) reviewCount from business t1 left join businessReview t2 on t1.id = t2.businessId where ' + likeStr, null, callback);
}

exports.queryPriceNull = function(callback){
	daoHelper.sql('select * from business where price is null', null, callback);
}

exports.updateBusiness = function(business, callback){
    //daoHelper.sql('update business set price = ?,tel=?,rating=?,taste=?,ambience=?,serving=?,fix=? where id=?',[business.price, business.tel,business.rating,business.taste,business.ambience,business.serving,business.fix, business.id], callback);
    daoHelper.sql('update business set img = ?,fix=? where id=?',[business.img, business.fix, business.id], callback);
}
exports.queryComments = function(obj, callback){
	daoHelper.sql('select * from businessReview where businessId=?', [obj.businessId], callback)
}
