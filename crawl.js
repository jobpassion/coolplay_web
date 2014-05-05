var http = require('http');
var request = require('request');
require('./config/config');
var businessService = require(ROOT + 'service/businessService');
var businessDao = require(ROOT + 'dao/businessDao');
var S = require('string');

var logger = require('log4js').getLogger(__filename);


function queryItem(itemId){
	var options = {
		host: 'nj.meituan.com',
		port: 80,
		path: '/deal/' + itemId + '.html',
		method: 'GET'
	};

	console.log("crawling " + itemId);
	var request = http.request(options,function(res){
		res.on('data',function(data){
			var res = {sourceId:itemId};
			var re = //;
			console.log(data.toString());
		});
	});

	request.end();
}
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
//function proxiedQueryItem(itemId){
//	var options = {
//		//host: '111.1.60.210',
//		//port: 80,
//		//path: 'http://www.dianping.com/search/category/5/10/g25474p5',
//		host: 'www.dianping.com',
//		port: 80,
//		path: '/search/category/5/10/g25474p5',
//        headers:headers,
//		method: 'GET'
//	};
//
//	console.log("crawling " + itemId);
//	var request = http.request(options,function(res){
//		res.on('data',function(data){
//			var res = {sourceId:itemId};
//			var re = //;
//			console.log(data.toString());
//		});
//	});
//
//	request.end();
//}

var todoItems = [];
function proxiedQueryPage(url, page){
	if(!url)
		return;
	//var options = {
	//	//host: '111.1.60.210',
	//	//port: 80,
	//	//path: 'http://www.dianping.com/search/category/5/10/g25474p5',
	//	host: 'www.dianping.com',
	//	port: 80,
	//	path: url,
    //    headers:headers,
	//	method: 'GET'config
	//};

	logger.info("crawling page " + url.url  + " page index:" + page);
	//var request = http.get(options,function(res){
    //        console.log(res);
	//		//console.log(data.toString());
    //        //var results = re.exec(data.toString());
    //        //console.log(results);
	//});


    var options = {
        url:url.url + "p" + page
        ,proxy:'http://' + proxy[proxy.length-1]
        ,headers:headers
    };
	next = false;
    request(options, function (error, response, body) {
		if(error){
			logger.error(error);
			currentPage--;
			next = true;
			nextProxy();
			return;
		}
		if(200!=response.statusCode){
			currentPage--;
			next = true;
			nextProxy();
			return;
		}
		
      if (!error && response.statusCode == 200) {
		var re = /<a href="\/shop\/(.*)" class="BL"/g;
		var matches;
		next = false;
		while (matches = re.exec(body)) {
			next = true;
			logger.info('pushing todo item:' + matches[1]);
			todoItems.push(matches[1]);
		}
		if(!next && urls.length>0){
			next = true;
			var url = urls.pop();
			businessDao.updateUrl(url);
			currentPage = 0;
		}
      }
    })
    
}
function decode(C) {  
        var digi=16;  
        var add= 10;  
        var plus=7;  
        var cha=36;  
        var I = -1;  
        var H = 0;  
        var B = "";  
        var J = C.length;  
        var G = C.charCodeAt(J - 1);  
        C = C.substring(0, J - 1);  
        J--;  
        for (var E = 0; E < J; E++) {  
            var D = parseInt(C.charAt(E), cha) - add;  
            if (D >= add) {  
                D = D - plus  
            }  
            B += (D).toString(cha);  
            if (D > H) {  
                I = E;  
                H = D  
            }  
        }  
        var A = parseInt(B.substring(0, I), digi);  
        var F = parseInt(B.substring(I + 1), digi);  
        var L = (A + F - parseInt(G)) / 2;  
        var K = (F - L) / 100000;  
        L /= 100000;  
        return {  
            lat: K,  
            lng: L  
        }  
}
var blockingItems = [];
function proxiedQueryItem(item){
    logger.info("crawling " + item);
    var options = {
        url:'http://www.dianping.com/shop/' + item
        ,proxy:'http://' + proxy[proxy.length-1]
        ,timeout:10000
        ,headers:headers
    };
	blockingItems.push(item);
    request(options, function (error, response, body) {
    	blockingItems.pop();
		if(error){
    		todoItems.push(item);
			logger.error(error);
			nextProxy();
			return;
		}
		if(200!=response.statusCode){
    		todoItems.push(item);
			nextProxy();
			return;
		}
      if (!error && response.statusCode == 200) {
        var re = /<h1 class="shop-title" itemprop="name itemreviewed">([^<]*)<\/h1>/;
        var results = re.exec(body);
        var res = {sourceId:item
            ,name:S(results[1]).trim().s
            ,source:'dianping'
            ,sourceId:item
        };
        if(body.indexOf('分店')!=-1){
            res.hasBranch = 1;
        }
        re = /<span itemprop="street-address">([^<]*)<\/span>/;
        results = re.exec(body);
        res.address = S(results[1]).trim().s;
        re = /<span class="region" itemprop="locality region">(.*)<\/span>/;
        results = re.exec(body);
        res.region = S(results[1]).trim().s;
        re = /<span class="bread-name" itemprop="title">([^<]*)<\/span>/g;
        results = re.exec(body);
        results = re.exec(body);
        results = re.exec(body);
        res.region2 = S(results[1]).trim().s;
        res.category1 = '美食';
        results = re.exec(body);
        if(results)
            res.category2 = S(results[1]).trim().s;
        results = re.exec(body);
		if(results)
        	res.category3 = S(results[1]).trim().s;
		re = /poi: ["'](.*)["']/;
        results = re.exec(body);
        if(!results){
            logger.error('parse poi error on item:' + item);
            logger.info(body);
            next = false;
            return;
        }
        var poi = S(results[1]).trim().s;
		poi = decode(poi);
		res.latitude = poi.lat;
		res.longitude = poi.lng;
        console.log(res);
		businessService.insert(res);
        //console.log(body) // Print the google web page.
      }
    });
}
setInterval(function(){
	if(proxy.length==0)
		return;
	if(todoItems.length>0 && blockingItems.length < 3)
		proxiedQueryItem(todoItems.pop());
}, 1000);
var currentPage = 0;
var next = true;
var urls = [];
var count = 0;
setInterval(function(){
	if(proxy.length==0)
		return;
	count++;
	if(urls.length > 0){
		if(todoItems.length==0 && next)
			proxiedQueryPage(urls[urls.length - 1], ++currentPage);
	}else{
		if(count >= 30){
			queryUrls();
		}
	}
}, 10000);

function queryUrls(){
	businessDao.queryUrls(function(results, error){
		if(error)
			logger.error(error);
		else if(results)
			urls = urls.concat(results);

	});
}
//proxiedQueryPage('http://www.dianping.com/search/category/5/10/g4581r65', 1);
//queryItem(5986025);
//proxiedQueryItem(5538379);
var proxy = [];

function updateProxy(){
    request('http://www.site-digger.com/html/articles/20110516/proxieslist.html', function (error, response, body) {
		var re = /<td>([\d.:]*)<\/td>/g;
		var matches;
		proxy = [];
		while (matches = re.exec(body)) {
			logger.info(matches[1]);
			proxy.push(matches[1]);
		}
	});
}
updateProxy();
queryUrls();
function nextProxy(){
	proxy.pop();
	if(proxy.length<=3){
		updateProxy();
	}
}
