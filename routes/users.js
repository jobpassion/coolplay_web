var express = require('express');
var router = express.Router();
var userDao = require(ROOT + 'dao/userDao');

/* GET users listing. */
router.get('/', function(req, res) {
    userDao.insert({name:'abc'});
  res.send('respond with a resource');
});

module.exports = router;
