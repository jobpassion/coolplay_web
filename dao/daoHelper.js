var config = require('../config/config');
var log4js = require('log4js');
var mysql = require('mysql');
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
        var query = connection.query(_sql, _args, function(err, result) {
            logger.debug('sql executed');
			connection.release();
            if(callback){
                callback(result, err);
            }else{
				logger.error(err);
			}
        });

    });

}
exports.sql = sql;

