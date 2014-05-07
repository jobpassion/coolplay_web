require('./config/config');
var daoHelper = require(ROOT + 'dao/daoHelper');
var geohash = require('ngeohash');
var log4js = require('log4js');
var logger = log4js.getLogger(__filename);

function pagedQuery(){
    daoHelper.sql('select * from business where geohash is null and latitude is not null and longitude is not null limit 0, 100', null, function(results){
        for(var i in results){
            var result = results[i];
            if(result.latitude && result.longitude){
                result.geohash = geohash.encode(result.latitude, result.longitude);
                daoHelper.sql('update business set geohash = ? where id = ?', [result.geohash, result.id]);
                logger.info('succes fix :' + result.id);

            }
        }
        setTimeout(function(){
            pagedQuery();
        }, 3000);
    });
}
pagedQuery();
