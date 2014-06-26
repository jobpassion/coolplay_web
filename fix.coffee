pagedQuery = ->
  daoHelper.sql "select * from business where geohash is null and latitude is not null and longitude is not null limit 0, 100", null, (results) ->
    for i of results
      result = results[i]
      if result.latitude and result.longitude
        result.geohash = geohash.encode(result.latitude, result.longitude)
        daoHelper.sql "update business set geohash = ? where id = ?", [
          result.geohash
          result.id
        ]
        logger.info "succes fix :" + result.id
    setTimeout (->
      pagedQuery()
      return
    ), 3000
    return

  return
require "./config/config"
daoHelper = require(ROOT + "dao/daoHelper")
geohash = require("ngeohash")
log4js = require("log4js")
logger = log4js.getLogger(__filename)
pagedQuery()
