//var agent = require('webkit-devtools-agent');
var proxyQuery = require('./proxyQuery');
var daoHelper = require(ROOT + 'dao/daoHelper');
var businessDao = require(ROOT + 'dao/businessDao');
var logger = require('log4js').getLogger(__filename);
var env = require('jsdom').env;
var jquery = require('jquery');
var S = require('string');

var todo = [];
function interval1(){
	logger.info('[' + __function + ':' + __line + '] todo size ' + todo.length);
	if(todo.length>10){
		setTimeout(function(){
			interval1();
		}, 10000);
		return;
	}
    daoHelper.sql('select id, sourceId from business where fix2 is null limit 0, 100', null, function(results){
		todo = todo.concat(results);
		setTimeout(function(){
			interval1();
		}, 10000);
	});
}

interval1();
function interval2(quali){
	logger.info('[' + __function + ':' + __line + '] thread:' + quali);

	if(todo.length==0){
		setTimeout(function(){interval2(quali)}, 1000);
		return;
	}

	var obj = todo.pop();
	proxyQuery.query('http://www.dianping.com/shop/' + obj.sourceId + '/review_more', function(error, response, body){
		logger.info('[' + __function + ':' + __line + '] queried item:' + obj.sourceId + '  with statusCode ' + response.statusCode);
		env(body, function (errors, window) {
			/*
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
			*/
			var $ = jquery(window);

			var list = $('.comment-list>ul>li');
			var objList = [];
			for(var i=0; i<list.length; i++){
				var o = $(list[i]);
				var o2 = {};
				o2.sourceId = o.attr('id').substr(4);
				o2.businessId = obj.id;
				var o3 = o.find('.name>a');
				o2.userName = o3.text();
				o2.userSourceId = o3.attr('href');
				o2.userSourceId = o2.userSourceId.substr(8);
				o2.createDate = o.find('.time').text();
				o2.content = S(o.find('.comment-txt').children().text()).trim().s;
				if(o.find('.item-rank-rst').attr('class') && o.find('.item-rank-rst').attr('class').length>22)
				o2.rateStatus = o.find('.item-rank-rst').attr('class').substr(22);
				if(o2.rateStatus && o2.rateStatus.length>0)
					o2.rateStatus = o2.rateStatus.substring(0,1);
				//if(o.find('.comm-per').text().length>5)
					//o2.price = o.find('.comm-per').text().substr(5);
				var commentrst = o.find('.comment-rst').text();
				if(commentrst.length>0){
					var re = /口味(\d+)/g;
					var matches;
					while (matches = re.exec(commentrst)) {
						o2.taste = matches[1];
					}
					re = /环境(\d+)/g;
					while (matches = re.exec(commentrst)) {
						o2.ambience = matches[1];
					}
					re = /服务(\d+)/g;
					while (matches = re.exec(commentrst)) {
						o2.serving = matches[1];
					}
					re = /人均  ￥(\d+)/g;
                    commentrst = o.find('.comm-per').text();
					while (matches = re.exec(commentrst)) {
						o2.price = matches[1];
					}
				}
				var o4 = o.find('.comment-recommend');
				o2.recommand = '';
				o2.park = '';
                o2.recommandAmbience = '';
                o2.recommandFeature = '';
				for(var j=0; o4.length>0&&j<o4.length; j++){
					if($(o4[j]).text().indexOf('推荐菜')>=0){
						for(var k=0; k<$(o4[j]).find('a').length; k++){
							o2.recommand += ' ' + $($(o4[j]).find('a')[k]).text();
						}
					}else if($(o4[j]).text().indexOf('停车信息')>=0){
						for(var k=0; k<$(o4[j]).find('a').length; k++){
							o2.park += ' ' + $($(o4[j]).find('a')[k]).text();
						}
					}else if($(o4[j]).text().indexOf('餐厅氛围')>=0){
						for(var k=0; k<$(o4[j]).find('a').length; k++){
							o2.recommandAmbience += ' ' + $($(o4[j]).find('a')[k]).text();
						}
					}else if($(o4[j]).text().indexOf('餐厅特色')>=0){
						for(var k=0; k<$(o4[j]).find('a').length; k++){
							o2.recommandFeature += ' ' + $($(o4[j]).find('a')[k]).text();
						}
					}
				}

				var o5 = o.find('.thumb').find('img');
				o2.shopPhoto = '';
				if(o5.length>0){
					for(var j=0; j<o5.length; j++){
						o2.shopPhoto += ' ' + $(o5[j]).attr('src');
					}
				}
				objList.push(o2);

			}

		

            obj.fix2 =1;
            logger.info('[' + __function + ':' + __line + '] ' + JSON.stringify(obj));
			daoHelper.sql('update business set fix2=? where id=?',[obj.fix2, obj.id], 
            function(results, error){
                if(error){
                    logger.error('[' + __function + ':' + __line + '] ' + error);
                }
            logger.info('[' + __function + ':' + __line + '] succed saved item:' + obj.sourceId);
                
            });
            for(var i=0; i<objList.length; i++){
                save(objList[i]);
            }
			window.close();
		  });
		setTimeout(function(){interval2(quali)}, 1000);
	
	});	
}
function save(obj){
                daoHelper.sql('select * from businessReview where sourceId = ?',[obj.sourceId],function(results, error){
                    if(results.length==0){
                        daoHelper.sql('insert into businessReview set ?',obj, 
                            function(results, error){
                                if(error){
                                    logger.error('[' + __function + ':' + __line + '] ' + error);
                                }
                                logger.info('[' + __function + ':' + __line + '] succed saved item:' + obj.sourceId);
                            });
                    }
                });
 
}
interval2(1);
interval2(2);
interval2(3);


