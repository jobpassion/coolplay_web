
#var geohash = obj.geohash;
#geohash = geohash.substr(0, 6);

#var hashArr = ngeohash.neighbors(geohash);

#for(var i in results){
#	var o  = results[i];
#	o.distance = geolib.getDistance(
#		{latitude: obj.latitude, longitude: obj.longitude}, 
#		{latitude: o.latitude, longitude: o.longitude}
#	);
#}

#logger.info(results);
end = (client) ->
  client.end()
  return
businessDao = require(ROOT + "dao/businessDao")
businessAddressDao = require(ROOT + "dao/businessAddressDao")
businessImageDao = require(ROOT + "dao/businessImageDao")
businessPromotionDao = require(ROOT + "dao/businessPromotionDao")
businessReviewDao = require(ROOT + "dao/businessReviewDao")
redisHelper = require(ROOT + "dao/redisHelper")
config = require(ROOT + "config/config")
geolib = require("geolib")
ngeohash = require("ngeohash")
logger = require("log4js").getLogger(__filename)
util = require("util")
dateutil = require("dateutil")
exports.insert = (business, callback) ->
  businessDao.queryBySourceId business.sourceId, (results, error) ->
    businessDao.insert business, callback  if results.length is 0
    return

  return

exports.queryNearby = (obj, callback) ->
  obj.geohash = ngeohash.encode(obj.latitude, obj.longitude)
  if config.local
    callback()
    return
  redisHelper (err, client) ->
    unless err
      client.get "geohash-" + obj.geohash + "-p0", (err, reply) ->
        client.end()
        unless reply
          arr = []
          hashArr = ngeohash.bboxes(1 * obj.latitude - 0.01, 1 * obj.longitude - 0.01, 1 * obj.latitude + 0.01, 1 * obj.longitude + 0.01, 6)
          businessDao.queryGeoLike hashArr, (results) ->
            arr = geolib.orderByDistance(obj, results)
            for i of arr
              distance = arr[i].distance
              arr[i] = results[arr[i].key]
              arr[i].distance = distance
            i = 0
            info = total: arr.length
            while arr.length > 0
              subArr = arr.splice(0, 100)
              if i is 0
                logger.error "[" + __function + ":" + __line + "] " + "response"
                callback subArr
              redisHelper (err, client) ->
                client.set "geohash-" + obj.geohash + "-p" + i, JSON.stringify(subArr), (err, reply) ->
                  client.end()
                  return

                return

              i++
            info.pNum = i
            redisHelper (err, client) ->
              client.set "geohash-info-" + obj.geohash, JSON.stringify(info), (err, reply) ->
                client.end()
                return

              return

            callback arr
            return

        else
          arr = JSON.parse(reply)
          callback arr
        return

    return

  return

exports.queryComments = (obj, callback) ->
  businessDao.queryComments obj, (results) ->
    for obj of results
      obj = results[obj]
      if util.isDate(obj.createDate)
        obj.createDate.setHours obj.createDate.getHours() + 8
        obj.createDate = dateutil.format(obj.createDate, "Y-m-d H:i")
      else
        obj.createDate = ""
    callback results
    return

  return

exports.addReview = (obj, callback) ->
  businessReviewDao.insert obj, callback
  return
