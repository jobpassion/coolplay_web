var config = require('../config/config');
var mysql = require('mysql');
var log4js = require('log4js');
var logger = log4js.getLogger(__filename);
var pool  = mysql.createPool({
    host     : config.dbHost,
    user     : config.dbUser,
    database     : config.dbDatabase,
    password : config.dbPassword
});
logger.debug('db initialized');
function sql(_sql, _args, callback){
    var connection = pool.getConnection(function(err, connection) {
        if(err)
            logger.error(err);
        var query = connection.query(_sql, _args, function(err, result) {
            logger.debug('sql executed');
			connection.release();
			if(err)
				logger.error(err);
            if(callback){
                callback(result, err);
            }else{
				//logger.error(err);
			}
        });

    });

}
exports.sql = sql;

