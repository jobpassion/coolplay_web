// Generated by CoffeeScript 1.8.0
(function() {
  var daoHelper;

  daoHelper = require("./daoHelper");

  exports.insert = function(businessAddress, callback) {
    daoHelper.sql("insert into businessAddress set ?", businessAddress, callback);
  };

}).call(this);
