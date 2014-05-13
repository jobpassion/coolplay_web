var request = require('request');
require('./config/config');
var logger = require('log4js').getLogger(__filename);
var headers = {
            Accept:'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Encoding':'deflate,sdch'
            ,'Accept-Language':'zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4'
            ,'Cache-Control':'no-cache'
            ,Connection:'keep-alive'
            ,Host:'www.dianping.com'
            ,Pragma:'no-cache'
            ,'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
			,'Cookie':'_hc.v="\"3b801394-1439-48f9-bc20-57d1b5a84d66.1398687560\""; tc=5; abtest="47,122\|44,107\|45,116"; is=334431760877; ano=50qPs41kzwEkAAAAZDZjNzQ2OGYtZWM4Ni00OTllLWI1Y2QtZTg3YTc4NzRmYmFkEMAwn-18UdrOhDUEMB239uccdts1; sid=d5lk3z2oichkou55pxchgn45; PHOENIX_ID=0a010406-145af3c4836-315aa; JSESSIONID=C83F1032948A6ECB0BBB3C37A2EBBBF1; aburl=1; cy=5; cye=nanjing; __utma=1.284892197.1398687561.1398779639.1398813793.5; __utmb=1.57.10.1398813793; __utmc=1; __utmz=1.1398687561.1.1.utmcsr=google.com.hk|utmccn=(referral)|utmcmd=referral|utmcct=/; s_ViewType=1; ab=; lb.dp=1141113098.20480.0000'
        };

var options = {
        timeout:20000
        ,headers:headers
    };
var proxy = [];

function updateProxy(){
	if(proxy.length>0){
		proxy.pop();
	}else{
		logger.info('[' + __function + ':' + __line + '] start query new proxies');
    request({url:'http://www.site-digger.com/html/articles/20110516/proxieslist.html', timeout:10000}, function (error, response, body) {
		if(error)
		    logger.error(error);
		logger.info('[' + __function + ':' + __line + ']  queried new proxies');
		var re = /<td>([\d.:]*)<\/td>/g;
		var matches;
		proxy = [];
		while (matches = re.exec(body)) {
			logger.info(matches[1]);
			proxy.push(matches[1]);
		}
		block = false;
	});
	}
}
//updateProxy();
var block = false;
var blockingItems = [];
var requesting = [];
var cancelItems = [];

function intervalQuery(){
	if(blockingItems.length==0)
		return;
	var obj = blockingItems.pop();
	exports.query(obj.url, obj.callback);
}

setInterval(function(){
	intervalQuery();
}, 3000);

exports.query = function(url, callback){
	var obj = {url:url, callback:callback};
	if(block){
		blockingItems.push(obj);
		return;
	}
	if(proxy.length==0){
		block = true;
		blockingItems.push(obj);
		updateProxy();
		return;
	}
	requesting.push(obj);
    options.proxy = 'http://' + proxy[proxy.length-1];
	options.url = url;
    request(options, function (error, response, body) {
		if(error){
			logger.error('[' + __function + ':' + __line + '] ' + error);
		}
		var idx = cancelItems.indexOf(obj);
		if(idx>-1){
			blockingItems.push(obj);
			cancelItems.splice(idx,1);
			return;
		}
		if(error || 403==response.statusCode){
			block = true;
			blockingItems.push(obj);

			for(var i in requesting){
				if(requesting[i]==obj)
					continue;
				cancelItems.push(requesting[i]);
			}
			requesting = [];
			updateProxy();
			return;
		}
		for(var i in requesting){
			if(obj==requesting[i]){
				requesting.splice(i,1);
			}
		}
		callback(error, response, body);

	});
}
