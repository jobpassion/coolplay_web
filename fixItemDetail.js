var proxyQuery = require('./proxyQuery');
var daoHelper = require(ROOT + 'dao/daoHelper');
var logger = require('log4js').getLogger(__filename);
var env = require('jsdom').env;
var jquery = require('jquery');
var S = require('string');

var todo = [];
function interval1(){
	if(todo.length>10){
		return;
	}
    daoHelper.sql('select id, sourceId from business where price is null limit 0, 100', null, function(results){
		todo = todo.concat(results);
		setTimeout(function(){
			interval1();
		}, 10000);
	});
}

interval1();
function interval2(){
	if(todo.length==0){
		setTimeout(function(){interval2()}, 1000);
		return;
	}

	var obj = todo.pop();
	proxyQuery.query('http://www.dianping.com/shop/' + obj.sourceId, function(error, response, body){
		logger.info('[' + __function + ':' + __line + '] queried item:' + obj.sourceId + '  with statusCode ' + response.statusCode);
		env(body, function (errors, window) {

			var $ = jquery(window)
			  ;
			var re = /   ¥([\d]+)/g;
			var matches;
			while (matches = re.exec(body)) {
				obj.price = matches[1];
			}
			var tel = $('.call');
			tel = tel.text();
			tel = S(tel).trim().s;
			obj.tel = tel;

		  });
		setTimeout(function(){interval2()}, 1000);

	
	});	
}
interval2();


