config = require(ROOT + "config/config")
request = require 'solr-client'
logger = require("log4js").getLogger(__filename)

options = {
        url:'https://solr-fanhua.rhcloud.com/coolweb_collection/select?q=*:*&fq=%7B!geofilt%7D&sort=geodist()+asc&rows=200&fl=*%2Cscore%2Cdistance%3Ageodist()&wt=json&indent=true&spatial=true&pt=32.0694%2C118.77998&sfield=location'
        ,timeout:100000
    };
client = solr.createClient(config.solr)

queryNearby = (param, callback)->
  query = client.createQuery()
  				  .q('laptop')
  				  .dismax()
  				  .qf({title_t : 0.2 , description_t : 3.3})
  				  .mm(2)
  				  .start(0)
  				  .rows(10)
  client.search query,(err,obj)->
    if err
      console.log err
