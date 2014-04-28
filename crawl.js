var http = require('http');


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
function proxiedQueryItem(itemId){
	var options = {
		host: '111.1.60.210',
		port: 80,
		path: 'http://www.dianping.com/search/category/5/10/g25474p5',
		//host: 'www.dianping.com',
		//port: 80,
		//path: '/search/category/5/10/g25474p5',
        headers:{
            Accept:'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Encoding':'deflate,sdch'
            ,'Accept-Language':'zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4'
            ,'Cache-Control':'no-cache'
            ,Connection:'keep-alive'
            ,Host:'www.dianping.com'
            ,Pragma:'no-cache'
            ,'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'
        },
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

//queryItem(5986025);
proxiedQueryItem();
