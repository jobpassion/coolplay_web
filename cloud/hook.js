// Generated by CoffeeScript 1.8.0
(function() {
  var config, randomName, userDao;

  config = require("cloud/config/config");

  userDao = require(config.ROOT + "dao/userDao");

  randomName = require('chinese-random-name');

  AV.Cloud.beforeSave('Favorite', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('favoriteCount', 1);
    return userDao.save(post, function(error, result) {
      return post.fetch({
        success: function(post) {
          favo.set('publishType', post.get('publishType'));
          favo.save();
          return response.success();
        },
        error: function(post, error) {}
      });
    });
  });

  AV.Cloud.beforeDelete('Favorite', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('favoriteCount', -1);
    return userDao.save(post, function(error, result) {
      return response.success();
    });
  });

  AV.Cloud.beforeSave('Like', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('likeCount', 1);
    return userDao.save(post, function(error, result) {
      return response.success();
    });
  });

  AV.Cloud.beforeDelete('Like', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('likeCount', -1);
    return userDao.save(post, function(error, result) {
      return response.success();
    });
  });

  AV.Cloud.beforeSave('Comment', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('commentCount', 1);
    return userDao.save(post, function(error, result) {
      return response.success();
    });
  });

  AV.Cloud.beforeDelete('Comment', function(request, response) {
    var favo, post;
    favo = request.object;
    post = favo.get('post');
    post.increment('commentCount', -1);
    return userDao.save(post, function(error, result) {
      return response.success();
    });
  });

  AV.Cloud.beforeSave('Album', function(request, response) {
    var album;
    album = request.object;
    return userDao.queryByParam('_File', {
      name: album.get('filename')
    }, function(error, results) {
      var file;
      if (!error && results.length > 0) {
        file = results[0];
        request.object.set('file', file);
        return response.success();
      }
    });
  });

  AV.Cloud.beforeSave('Publish', function(request, response) {
    var post;
    post = request.object;
    if (1 === post.get('anonymous')) {
      post.set('anonymousNickname', randomName.generate());
      return userDao.queryByParam('_File', {
        name: 'avatar_female_' + Math.floor(1 + Math.random() * 1578) + '.jpg'
      }, function(error, results) {
        var file;
        if (!error && results.length > 0) {
          file = results[0];
          post.set('anonymousAvatar', file.get('url'));
          return response.success();
        }
      });
    } else {
      return response.success();
    }
  });

  AV.Cloud.afterDelete('Publish', function(request) {
    var Favorite, query;
    Favorite = userDao.AVClass('Favorite');
    query = new AV.Query(Favorite);
    query.equalTo('post', request.object);
    return query.destroyAll({
      success: function() {},
      error: function(error) {}
    });
  });

  AV.Cloud.beforeSave('_User', function(request, response) {
    var post;
    post = request.object;
    post.set('mobilePhoneVerified', true);
    return response.success();
  });

  AV.Cloud.afterUpdate('_User', function(request, response) {
    var post;
    post = request.object;
    post.set('mobilePhoneVerified', true);
    return userDao.save(post, function(error, result) {});
  });

}).call(this);
