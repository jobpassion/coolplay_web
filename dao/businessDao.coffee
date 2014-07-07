daoHelper = require("./daoHelper")
exports.insert = (business, callback) ->
  daoHelper.sql "insert into business set ?", business, callback
  return

exports.queryBySourceId = (sourceId, callback) ->
  daoHelper.sql "select * from business where sourceId = ?", [sourceId], callback
  return

exports.queryUrls = (callback) ->
  daoHelper.sql "select * from tmpUrls where complete is null", null, callback
  return

exports.updateUrl = (url, callback) ->
  daoHelper.sql "update tmpUrls set complete = 1 where id = ?", [url.id], callback
  return

exports.queryGeoLike = (geoHash, callback) ->
  likeStr = ""
  for i of geoHash
    likeStr += " or t1.geohash like '" + geoHash[i] + "%'"
  likeStr = likeStr.substr(4)
  
  #daoHelper.sql('select * from business where ' + likeStr, null, callback);
  daoHelper.sql "select t1.*, count(t2.id) reviewCount from business t1 left  join businessReview t2 on t1.id = t2.businessId where " + likeStr + " group by t1.id ", null, callback
  return

exports.queryPriceNull = (callback) ->
  daoHelper.sql "select * from business where price is null", null, callback
  return

exports.updateBusiness = (business, callback) ->
  
  #daoHelper.sql('update business set price = ?,tel=?,rating=?,taste=?,ambience=?,serving=?,fix=? where id=?',[business.price, business.tel,business.rating,business.taste,business.ambience,business.serving,business.fix, business.id], callback);
  daoHelper.sql "update business set img = ?,fix=? where id=?", [
    business.img
    business.fix
    business.id
  ], callback
  return

exports.queryComments = (obj, callback) ->
  daoHelper.sql "select * from businessReview where businessId=?", [obj.businessId], callback
  return
exports.queryByIds = (ids, callback) ->
  if ids.length == 0
    callback null, []
    return
  whereCause = 'id in (0'
  whereCause += ', ' + id.id.substr(9) for id in ids
  whereCause += ')'
  daoHelper.sql "select * from business where " + whereCause, null, callback
  return
