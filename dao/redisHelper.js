var config = require('../config/config');
var log4js = require('log4js');
var logger = log4js.getLogger(__filename);
var poolModule = require('generic-pool');


var pool = poolModule.Pool({
	name     : 'redis',
	create   : function(callback) {
		var client = require('redis').createClient(config.redisPort, config.redisHost);  
		callback(null, client);  
	},
	destroy  : function(client) { client.quit(); }, //当超时则释放连接
	max      : 10,   //最大连接数
	idleTimeoutMillis : 30000,  //超时时间
	log : true,  
});

function release(client){
	pool.release(client);
}
module.exports = function(callback){
	pool.acquire(function(err, client) {
		if(err)
			logger.error('[' + __function + ':' + __line + '] ' + err);
		client.end = function(){release(client)};
		callback(err, client);
	});
};
