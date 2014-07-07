config = require(ROOT + "config/config")
solr = require 'solr-client'
logger = require("log4js").getLogger(__filename)

options = {
        url:'https://solr-fanhua.rhcloud.com/coolweb_collection/select?q=*:*&fq=%7B!geofilt%7D&sort=geodist()+asc&rows=200&fl=*%2Cscore%2Cdistance%3Ageodist()&wt=json&indent=true&spatial=true&pt=32.0694%2C118.77998&sfield=location'
        ,timeout:100000
    };
client = solr.createClient(config.solr)

exports.queryNearby = (param, callback)->
  query = client.createQuery()
      .q('text:' + if param.q then param.q else '*')
  				  .fq('{!geofilt}')
  				  .sort('geodist() asc')
  				  .rows(100)
                  .start(if param.start then param.start else 0)
                  .d(if param.d then param.d else 100)
  				  .fl('*,score,distance:geodist()')
  				  .spatial(true)
  				  .pt('32.0694,118.77998')
  				  .sfield('location')
  client.search query,(err,obj)->
    if err
      logger.error "[" + __function + ":" + __line + "] " + err
      callback err
    callback err,obj.response.docs
