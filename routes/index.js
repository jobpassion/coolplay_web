var express = require('express');
var router = express.Router();
var businessService = require(ROOT + 'service/businessService');

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});


router.post('/queryNearby', function(req, res){
	businessService.queryNearby(req.body, function(results){
	//businessService.queryNearby({latitude:32.06697, longitude:118.77793}, function(results){
		res.json(results);
	});
})

module.exports = router;
