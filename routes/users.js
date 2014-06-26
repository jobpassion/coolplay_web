var express = require('express');
var router = express.Router();
var userService = require(ROOT + 'service/userService');

/* GET users listing. */
router.get('/', function(req, res) {
  res.send('respond with a resource');
});
router.all('/register', function(req, res) {
    var user = req.query;
    userService.register(user, function(result, succ){
        res.json(result);
    });
});
router.all('/thirdLogin', function(req, res){
	var user = req.body;
    userService.thirdLogin(user, function(result, succ){
        res.json(result);
    });
});
router.all('/addUserAction', function(req, res)){
	var userAction = req.body;
	userService.addUserAction(userAction, function(result){
		res.json(result);
	})
}


router.all('/queryUserFavorite', function(req, res)){
	var params = req.body;
	userService.queryUserFavorite(params, function(result){
		res.json(result);
	});
}


router.all('/queryUserLike', function(req, res)){
	var params = req.body;
	userService.queryUserLike(params, function(result){
		res.json(result);
	});
}

module.exports = router;

