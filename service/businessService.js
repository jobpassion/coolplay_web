var businessDao = require(ROOT + 'dao/businessDao');
var businessAddressDao = require(ROOT + 'dao/businessAddressDao');
var businessImageDao = require(ROOT + 'dao/businessImageDao');
var businessPromotionDao = require(ROOT + 'dao/businessPromotionDao');
var businessReviewDao = require(ROOT + 'dao/businessReviewDao');
var geolib = require('geolib');
var ngeohash = require('ngeohash');
var logger = require('log4js').getLogger(__filename);


exports.insert = function(business, callback){
	businessDao.queryBySourceId(business.sourceId, function(results, error){
		if(results.length==0){
			businessDao.insert(business, callback);
		}
		
	})
}


exports.queryNearby = function(obj, callback){
	obj.geohash = ngeohash.encode(obj.latitude, obj.longitude);
	var geohash = obj.geohash;
	geohash = geohash.substr(0, 6);
	var arr = [];
	businessDao.queryGeoLike(geohash, function(results){
		//for(var i in results){
		//	var o  = results[i];
		//	o.distance = geolib.getDistance(
		//		{latitude: obj.latitude, longitude: obj.longitude}, 
		//		{latitude: o.latitude, longitude: o.longitude}
		//	);
		//}
		arr = geolib.orderByDistance(obj, results);
		//logger.info(results);
		for(var i in arr){
			var distance = arr[i].distance;
			arr[i] = results[arr[i].key];
			arr[i].distance = distance;
		}
		callback(arr);
	});
}
