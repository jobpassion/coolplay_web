// Generated by CoffeeScript 1.8.0
(function() {
  var config, userService;

  config = require("cloud/config/config");

  userService = require('cloud/service/userService');

  require('cloud/hook');

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

  AV.Cloud.define("removeToLike", function(request, response) {
    return userService.removeToLike(request.user, request.params.post, function(error, result) {
      return response.success(result);
    });
  });

  AV.Cloud.define("addToFavorite", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    return userService.addToFavorite(currentUser, request.params.post, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("removeToFavorite", function(request, response) {
    userService.constructAVObject('Publish', request.params.post);
    return userService.removeToFavorite(request.user, request.params.post, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryLatestPublish", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryLatestPublish(request.params, function(error, results) {
      return response.success(userService.recursiveToJson(results));
    });
  });

  AV.Cloud.define("queryHotestPublish", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryHotestPublish(request.params, function(error, results) {
      return response.success(userService.recursiveToJson(results));
    });
  });

  AV.Cloud.define("queryCircleDetail", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryCircleDetail(request.params, function(error, results) {
      return response.success(userService.recursiveToJson(results));
    });
  });

  AV.Cloud.define("queryCommentsByPost", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.post = userService.constructAVObject('Publish', request.params.post);
    request.params.user = currentUser;
    return userService.queryCommentsByPost(request.params, function(error, results) {
      return response.success(results);
    });
  });

  AV.Cloud.define("queryFavorites", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryFavorites(request.params, function(error, results) {
      return response.success(results);
    });
  });

  AV.Cloud.define("queryLikes", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryLikes(request.params, function(error, results) {
      return response.success(results);
    });
  });

  AV.Cloud.define("addCommentForPost", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    request.params.post = userService.constructAVObject('Publish', request.params.post);
    return userService.addCommentForPost(request.params, function(error, results) {
      return response.success(results);
    });
  });

  AV.Cloud.define("deleteContact", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.deleteContact(request.params, function(error, result) {
      return response.success(result);
    });
  });

  AV.Cloud.define("queryFriends", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryFriends(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("checkIfFriend", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.checkIfFriend(request.params, function(error, result) {
      return response.success(result);
    });
  });

  AV.Cloud.define("queryMyCircles", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryMyCircles(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryMyFavorites", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryMyFavorites(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryMyAlbum", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryMyAlbum(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryHisAlbum", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryHisAlbum(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryHisAlbumLast", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryHisAlbumLast(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("guessIt", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.guessIt(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("guessRight", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.guessRight(request.params, function(error, result) {
      return response.success(userService.recursiveToJson(result));
    });
  });

  AV.Cloud.define("queryWeiboFriends", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.queryWeiboFriends(request.params, function(error, result) {
      if (error) {
        return response.error(error);
      } else {
        return response.success(result);
      }
    });
  });

  AV.Cloud.define("searchNewFriend", function(request, response) {
    var currentUser;
    currentUser = AV.User.current();
    request.params.user = currentUser;
    return userService.searchNewFriend(request.params, function(error, result) {
      if (error) {
        return response.error(error);
      } else {
        return response.success(result);
      }
    });
  });

}).call(this);
