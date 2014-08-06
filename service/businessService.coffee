
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
#https://solr-fanhua.rhcloud.com/coolweb_collection/select?q=*:*&fq=%7B!geofilt%7D&sort=geodist()+asc&rows=200&fl=*%2Cscore%2Cdistance%3Ageodist()&wt=json&indent=true&spatial=true&pt=32.0694%2C118.77998&sfield=location&d=2
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
daoHelper = require(ROOT + "dao/daoHelper")
geoService = require(ROOT + "service/geoService")
exports.insert = (business, callback) ->
  businessDao.queryBySourceId business.sourceId, (results, error) ->
    businessDao.insert business, callback  if results.length is 0
    if callback
      callback()
    return

  return
  
queryFromSolr = (obj, callback) ->
  param = 
    start:obj.p * 100
    pt:obj.latitude + ',' + obj.longitude
    q:if obj.q then obj.q else '*'
  geoService.queryNearby param, (err, results) ->
    if err
      callback(err);
      return
    #callback err, results
    queryFromDB obj, results, callback
queryFromDB = (obj, ids, callback) ->
  businessDao.queryByIds ids, (results, err) ->
    if err
      callback err, null
      return
    idMap = {}
    idMap['business_' + i.id] = i for i in results
    results = []
    for i in ids
      j = idMap[i.id]
      j.distance = parseInt(i.distance * 1000)
      results.push j
    redisHelper (err, client) ->
      unless err
        client.set "geohash-" + obj.geohash + "-q" + obj.q + "-p" + obj.p, JSON.stringify(results), (err, reply) ->
          client.end()
      
    callback err, results


exports.queryNearby = (obj, callback) ->
  unless obj.p
    obj.p = 0
  unless obj.q
    obj.q = '*'
  obj.geohash = ngeohash.encode(obj.latitude, obj.longitude)
  #if config.local
  #  daoHelper.sql "select t1.*, count(t2.id) reviewCount from business t1 left  join businessReview t2 on t1.id = t2.businessId where " + 't1.id = 31' + " group by t1.id ", null, (results) ->
  #    callback(results)
  #  return
  redisHelper (err, client) ->
    unless err
      client.get "geohash-" + obj.geohash + "-q" + obj.q + "-p" + obj.p, (err, reply) ->
        client.end()
        unless reply
          ###
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
          ###
          queryFromSolr obj, callback

        else
          arr = JSON.parse(reply)
          callback null, arr
        return
    else
      queryFromSolr obj, callback
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
