var express = require('express');
var router = express.Router();
var businessService = require(ROOT + 'service/businessService');
var logger = require('log4js').getLogger(__filename);

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
})

module.exports = router;
