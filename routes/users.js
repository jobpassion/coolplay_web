var express = require('express');
var router = express.Router();
var userDao = require(ROOT + 'dao/userDao');

/* GET users listing. */
router.get('/', function(req, res) {
    userDao.insert({name:'abc'});
  res.send('respond with a resource');
});
router.get('/test', function(req, res) {
    res.json({a:1});
});
router.get('/register', function(req, res) {
    res.json({a:1});
});

module.exports = router;
