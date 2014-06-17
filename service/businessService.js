var businessDao = require(ROOT + 'dao/businessDao');
var businessAddressDao = require(ROOT + 'dao/businessAddressDao');
var businessImageDao = require(ROOT + 'dao/businessImageDao');
var businessPromotionDao = require(ROOT + 'dao/businessPromotionDao');
var businessReviewDao = require(ROOT + 'dao/businessReviewDao');
var redisHelper = require(ROOT + 'dao/redisHelper');
var config = require(ROOT + 'config/config');
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

	if(config.local){
		callback();
		return;
	}
	redisHelper(function(err, client) {
		if(!err){
		client.get('geohash-' + obj.geohash + '-p0',function(err, reply){
			client.end();	
			if(!reply){
				//var geohash = obj.geohash;
				//geohash = geohash.substr(0, 6);
				
				var arr = [];
				//var hashArr = ngeohash.neighbors(geohash);
				var hashArr = ngeohash.bboxes(1*obj.latitude - 0.01, 1*obj.longitude - 0.01, 1*obj.latitude + 0.01, 1*obj.longitude + 0.01, 6);
				businessDao.queryGeoLike(hashArr, function(results){
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
					var i=0;
					var info = {total:arr.length};
					for(; arr.length>0;i++){
						var subArr = arr.splice(0,100);
						if(i==0){
							logger.error('[' + __function + ':' + __line + '] ' + 'response');
							callback(subArr);
						}
						redisHelper(function(err, client) {
							client.set('geohash-' + obj.geohash + '-p' + i, JSON.stringify(subArr), function(err, reply){
								client.end();
							});
						});
					}
					info.pNum = i;
					redisHelper(function(err, client) {
						client.set('geohash-info-' + obj.geohash, JSON.stringify(info), function(err, reply){
							client.end();
						});
					});
				});
			
			}else{
				var arr = JSON.parse(reply);
				callback(arr);
			}
		});
		}
	});
}
function end(client){client.end();}
exports.queryComments = function(obj, callback){

	businessDao.queryComments(obj, function(results){
		for(var obj in results){
			obj = results[obj];
			if(util.isDate(obj.createDate)){
				obj.createDate.setHours(obj.createDate.getHours() + 8);
				obj.createDate = dateutil.format(obj.createDate, 'Y-m-d H:i');
			}else{
				obj.createDate = "";
			}
		}
		callback(results);
	}
	);
}

exports.addReview = function(obj, callback){
	businessReviewDao.insert(obj, callback);
}

