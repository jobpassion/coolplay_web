var http = require('http');
var request = require('request');
require('./config/config');
var businessService = require(ROOT + 'service/businessService');
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
            ,'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'
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

	logger.info("crawling page " + url  + " page index:" + page);
	//var request = http.get(options,function(res){
    //        console.log(res);
	//		//console.log(data.toString());
    //        //var results = re.exec(data.toString());
    //        //console.log(results);
	//});


    var options = {
        url:url + "p" + page
        ,headers:headers
    };
	next = false;
    request(options, function (error, response, body) {
		if(error)
			logger.error(error);
		
      if (!error && response.statusCode == 200) {
		var re = /<a href="\/shop\/(.*)" class="BL"/g;
		var matches;
		next = false;
		while (matches = re.exec(body)) {
			next = true;
			logger.info('pushing todo item:' + matches[1]);
			todoItems.push(matches[1]);
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
        ,headers:headers
    };
	blockingItems.push(item);
    request(options, function (error, response, body) {
		blockingItems.pop();
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
        res.category2 = S(results[1]).trim().s;
        results = re.exec(body);
		if(results)
        	res.category3 = S(results[1]).trim().s;
		re = /poi: ["'](.*)["']/;
        results = re.exec(body);
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
	if(todoItems.length>0 && blockingItems.length < 3)
		proxiedQueryItem(todoItems.pop());
}, 100);
var currentPage = 0;
var next = true;
setInterval(function(){
	if(todoItems.length==0 && next)
		proxiedQueryPage('http://www.dianping.com/search/category/5/10/g4581r1694', ++currentPage);
}, 10000);
//proxiedQueryPage('http://www.dianping.com/search/category/5/10/g4581r65', 1);
//queryItem(5986025);
//proxiedQueryItem(5538379);
