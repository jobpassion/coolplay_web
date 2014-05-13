var proxyQuery = require('./proxyQuery');
var daoHelper = require(ROOT + 'dao/daoHelper');
var businessDao = require(ROOT + 'dao/businessDao');
var logger = require('log4js').getLogger(__filename);
var env = require('jsdom').env;
var jquery = require('jquery');
var S = require('string');

var todo = [];
function interval1(){
	if(todo.length>10){
		return;
	}
    daoHelper.sql('select id, sourceId from business where fix is null limit 0, 100', null, function(results){
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
            re = /\d+/g;
			var tel = $('.call');
			tel = tel.text();
			tel = S(tel).trim().s;
			obj.tel = tel;
            obj.rating = $('meta[itemprop="rating"]').attr('content');
            if(!re.test(obj.rating)){
                obj.rating = null;
            }
            var t = $('.rst-taste').find('strong');
            obj.taste = $(t[1]).text();
            re = /\d+/g;
            if(!re.test(obj.taste)){
                obj.taste = null;
            }
            obj.ambience = $(t[2]).text();
            re = /\d+/g;
            if(!re.test(obj.ambience)){
                obj.ambience= null;
            }
            obj.serving = $(t[3]).text();
            re = /\d+/g;
            if(!re.test(obj.serving)){
                obj.serving= null;
            }
            obj.fix =1;
            logger.info('[' + __function + ':' + __line + '] ' + JSON.stringify(obj));
            businessDao.updateBusiness(obj, function(results, error){
                if(error){
                    logger.error('[' + __function + ':' + __line + '] ' + error);
                }
            logger.info('[' + __function + ':' + __line + '] succed saved item:' + obj.sourceId);
                
            });
		  });
		setTimeout(function(){interval2()}, 1000);

	
	});	
}
interval2();
interval2();
interval2();


