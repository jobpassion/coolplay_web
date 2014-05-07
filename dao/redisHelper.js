var config = require('../config/config');
var log4js = require('log4js');
var logger = log4js.getLogger(__filename);
var poolModule = require('./generic-pool.js');


var pool = poolModule.Pool({
	name     : 'redis',
	create   : function(callback) {
		var client = require('redis').createClient();  
		callback(null, client);  
	},
	destroy  : function(client) { client.quit(); }, //当超时则释放连接
	max      : 10,   //最大连接数
	idleTimeoutMillis : 30000,  //超时时间
	log : true,  
});

exports.redis = pool.acquire;
