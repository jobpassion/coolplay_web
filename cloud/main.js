// Generated by CoffeeScript 1.8.0
(function() {
  var config, userService;

  config = require("cloud/config/config");

  userService = require('cloud/service/userService');

  AV.Cloud.define("hello", function(request, response) {
    response.success("Hello world!2");
  });

  AV.Cloud.define("register", function(request, response) {
    return response.success("success");
  });

  AV.Cloud.define("addToLike", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    return userService.addToLike(currentUser, request.params.post, function(error, result) {
      return response.success(result);
    });
  });

  AV.Cloud.define("queryLatestPublish", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryLatestPublish(request.params, function(error, results) {
      return response.success(results);
    });
  });

}).call(this);
