var express = require('express');
var router = express.Router();
var businessService = require(ROOT + 'service/businessService');
var logger = require('log4js').getLogger(__filename);
var daoHelper = require(ROOT + 'dao/daoHelper');
var util = require('util');
var dateutil = require('dateutil');

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});


//router.get('/queryNearby', function(req, res){
router.all('/queryNearby', function(req, res){
	businessService.queryNearby(req.body, function(results){
	//businessService.queryNearby({latitude:32.06697, longitude:118.77793}, function(results){
		res.json(results);
	});
})
router.all('/queryComments', function(req, res){

	logger.info('[' + __function + ':' + __line + '] ' + JSON.stringify(req.body));
	if(!req.body.businessId){
		req.body = {businessId:120};
	}
	businessService.queryComments(req.body, function(results){
		res.json(results);
	});
});

router.all('/test', function(req, res){
	daoHelper.sql('select * from businessReview where businessId=4439', [], function(results){
		for(var obj in results){
			obj = results[obj];
			if(util.isDate(obj.createDate)){
				obj.createDate.setHours(obj.createDate.getHours() + 8);
				obj.createDate = dateutil.format(obj.createDate, 'y-m-d H:i');
			}else{
				obj.createDate = "";
			}
		}
		res.json(results);
	})

});

router.all('/addReview', function(req, res){
	if(!req.body.businessId){
		req.body = {businessId:120, userName:'redrum', content:'testContent'}
	}
	req.body.createDate = new Date();
	businessService.addReview(req.body, function(results, error){
		if(!error){
			res.json({success:1});
		}else{
			res.json({success:0});
		}
	});
});

module.exports = router;
