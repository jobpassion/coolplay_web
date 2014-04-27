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

queryItem(5986025);
