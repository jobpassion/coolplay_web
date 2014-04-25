var express = require('express');
var router = express.Router();
var userService = require(ROOT + 'service/userService');

/* GET users listing. */
router.get('/', function(req, res) {
  res.send('respond with a resource');
});
router.get('/register', function(req, res) {
    var user = req.query;
    userService.register(user, function(result, succ){
        res.json(result);
    });
});

module.exports = router;

