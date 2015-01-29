// Generated by CoffeeScript 1.8.0
(function() {
  var async, classMap, config, constructAVObject, queryFavorites, queryLikes, randomToken, recursiveToJson, simpleUser, userDao;

  config = require("cloud/config/config");

  randomToken = function() {
    return crypto.randomBytes(20).toString("hex");
  };

  userDao = require(config.ROOT + "dao/userDao");

  async = require("async");

  classMap = {};

  exports.addToLike = function(user, post, callback) {
    var publish;
    publish = AV.Object["new"]('Comment');
    publish.set('objectId', post);
    return userDao.queryByParam('Like', {
      author: user,
      post: publish
    }, function(error, results) {
      if (error) {
        return callback(error, null);
      } else {
        if (results.length > 0) {
          return callback(null, {
            result: 0
          });
        } else {
          return userDao.insert('Like', {
            author: user,
            post: publish
          }, function(error, result) {
            if (!error) {
              return userDao.get('Comment', post, function(error, comment) {
                comment.set('favorite', true);
                return callback(null, {
                  object: comment,
                  result: 1
                });
              });
            }
          });
        }
      }
    });
  };

  exports.removeToLike = function(user, post, callback) {
    var publish;
    publish = AV.Object["new"]('Comment');
    publish.set('objectId', post);
    return userDao.queryByParam('Like', {
      author: user,
      post: publish
    }, function(error, results) {
      var like;
      if (error) {
        return callback(error, null);
      } else {
        if (results.length > 0) {
          like = results[0];
          return userDao["delete"](like, function(error, result) {
            return userDao.get('Comment', post, function(error, result) {
              return callback(null, {
                object: result,
                result: 1
              });
            });
          });
        } else {
          return callback(null, {
            result: 0
          });
        }
      }
    });
  };

  exports.addToFavorite = function(user, post, callback) {
    var publish;
    publish = AV.Object["new"]('Publish');
    publish.set('objectId', post);
    return userDao.queryByParam('Favorite', {
      author: user,
      post: publish
    }, function(error, results) {
      if (error) {
        return callback(error, null);
      } else {
        if (results.length > 0) {
          return callback(null, {
            result: 0
          });
        } else {
          return userDao.insert('Favorite', {
            author: user,
            post: publish
          }, function(error, result) {
            if (!error) {
              return userDao.getAndInclude('Publish', post, ['author'], function(error, publish) {
                publish.set('favorite', true);
                return callback(null, {
                  object: publish,
                  result: 1
                });
              });
            }
          });
        }
      }
    });
  };

  exports.removeToFavorite = function(user, post, callback) {
    var publish;
    publish = AV.Object["new"]('Publish');
    publish.set('objectId', post);
    return userDao.queryByParam('Favorite', {
      author: user,
      post: publish
    }, function(error, results) {
      var favorite;
      if (error) {
        return callback(error, null);
      } else {
        if (results.length > 0) {
          favorite = results[0];
          return userDao["delete"](favorite, function(error, result) {
            return userDao.getAndInclude('Publish', post, ['author'], function(error, result) {
              return callback(null, {
                object: result,
                result: 1
              });
            });
          });
        } else {
          return callback(null, {
            result: 0
          });
        }
      }
    });
  };

  exports.queryLatestPublish = function(param, callback) {
    if (param.publishType === '2' && !param.user) {
      callback(null, []);
    }
    return userDao.queryLatestPublish(param, function(error, results1) {
      var post, _i, _len;
      for (_i = 0, _len = results1.length; _i < _len; _i++) {
        post = results1[_i];
        post.set('author', simpleUser(post.get('author')));
      }
      if (param.user) {
        return userDao.queryFavorites(param, function(error, results) {
          var favorite, favoriteMap, _j, _k, _len1, _len2;
          favoriteMap = {};
          for (_j = 0, _len1 = results.length; _j < _len1; _j++) {
            favorite = results[_j];
            favoriteMap[(favorite.get('post')).id] = 1;
          }
          for (_k = 0, _len2 = results1.length; _k < _len2; _k++) {
            post = results1[_k];
            if (favoriteMap[post.id]) {
              post.set('favorite', true);
            }
          }
          return callback(error, results1);
        });
      } else {
        return callback(error, results1);
      }
    });
  };

  exports.queryHotestPublish = function(param, callback) {
    return userDao.queryHotestPublish(param, function(error, results1) {
      var post, _i, _len;
      for (_i = 0, _len = results1.length; _i < _len; _i++) {
        post = results1[_i];
        post.set('author', simpleUser(post.get('author')));
      }
      if (param.user) {
        return queryFavorites(param, function(error, results) {
          var favorite, favoriteMap, _j, _k, _len1, _len2;
          favoriteMap = {};
          for (_j = 0, _len1 = results.length; _j < _len1; _j++) {
            favorite = results[_j];
            favoriteMap[(favorite.get('post')).id] = 1;
          }
          for (_k = 0, _len2 = results1.length; _k < _len2; _k++) {
            post = results1[_k];
            if (favoriteMap[post.id]) {
              post.set('favorite', true);
            }
          }
          return callback(error, results1);
        });
      } else {
        return callback(error, results1);
      }
    });
  };

  exports.queryCommentsByPost = function(param, callback) {
    return userDao.queryCommentsByPost(param, function(error, results1) {
      if (param.user) {
        return queryLikes({
          author: param.user,
          post: param.post
        }, function(error, results) {
          var favorite, favoriteMap, post, _i, _j, _len, _len1;
          favoriteMap = {};
          for (_i = 0, _len = results.length; _i < _len; _i++) {
            favorite = results[_i];
            favoriteMap[(favorite.get('post')).id] = 1;
          }
          for (_j = 0, _len1 = results1.length; _j < _len1; _j++) {
            post = results1[_j];
            if (favoriteMap[post.id]) {
              post.set('favorite', true);
            }
          }
          return callback(error, results1);
        });
      } else {
        return callback(error, results1);
      }
    });
  };

  queryLikes = function(param, callback) {
    var paramCopy;
    paramCopy = {
      metaUnLimit: true
    };
    if (param.user) {
      paramCopy.user = param.user;
    }
    return userDao.queryByParam('Like', paramCopy, callback);
  };

  exports.queryLikes = queryLikes;

  queryFavorites = function(param, callback) {
    if (param.user) {
      return userDao.queryFavorites(param, callback);
    }
  };

  exports.queryFavorites = queryFavorites;

  constructAVObject = function(_class, objectId) {
    var avObject;
    avObject = AV.Object["new"](_class);
    avObject.set('objectId', objectId);
    return avObject;
  };

  exports.constructAVObject = constructAVObject;

  exports.addCommentForPost = function(param, callback) {
    var comment;
    comment = AV.Object["new"]('Comment');
    comment.set('content', param.content);
    comment.set('author', param.user);
    comment.set('post', param.post);
    return userDao.save(comment, function(error, comment) {
      return callback(error, 1);
    });
  };

  recursiveToJson = function(obj) {
    var i, key, value, _ref;
    if (!obj) {
      return obj;
    }
    if (Array.isArray(obj)) {
      for (i in obj) {
        obj[i] = recursiveToJson(obj[i]);
      }
    } else {
      if (obj.toJSON) {
        _ref = obj.attributes;
        for (key in _ref) {
          value = _ref[key];
          obj.set(key, recursiveToJson(value));
        }
        obj = obj.toJSON();
      } else if (obj.thumbnailURL) {
        obj = {
          name: obj.name(),
          metaData: obj.metaData(),
          url: obj.url(),
          size: obj.size()
        };
      } else {
        for (key in obj) {
          value = obj[key];
          if (value && value.toJSON) {
            obj[key] = recursiveToJson(value);
          }
        }
      }
    }
    return obj;
  };

  exports.recursiveToJson = recursiveToJson;

  simpleUser = function(user) {
    user = user.toJSON();
    return {
      interests: user.interests,
      avatar: user.avatar,
      objectId: user.objectId,
      desc: user.desc,
      nickname: user.nickname
    };
  };

  exports.deleteContact = function(param, callback) {
    var him, me;
    me = param.user;
    him = param.him;
    return me.unfollow(him, {
      success: function() {
        var himUser;
        himUser = new AV.User();
        himUser.set('objectId', him);
        return himUser.fetch({
          success: function(himUser) {
            return himUser.unfollow(me.id, {
              success: function() {
                return callback(null, true);
              },
              error: function(error) {
                return console.log('error');
              }
            });
          }
        });
      },
      error: function(error) {}
    });
  };

  exports.queryCircleDetail = function(param, callback) {
    return userDao.queryByParam('Publish', {
      objectId: param.post
    }, function(error, results) {
      var post;
      if (!error && results.length > 0) {
        post = results[0];
        param.post = post;
        return exports.queryCommentsByPost(param, function(error, results) {
          post.set('comments', results);
          if (param.user) {
            return userDao.queryByParam('Favorite', {
              author: param.user,
              post: param.post
            }, function(error, results) {
              if (results.length > 0) {
                post.set('favorite', true);
              }
              return callback(error, post);
            });
          } else {
            return callback(error, post);
          }
        });
      }
    }, ['author'], ['author.nickname', 'author.avatar', 'backImageStr', 'shareCount', 'content', 'favoriteCount', 'commentCount']);
  };

  exports.queryFriends = function(param, callback) {
    return userDao.queryFriends(param, function(error, results) {
      var friend, newResults, _i, _len;
      newResults = [];
      if (!error) {
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          friend = results[_i];
          newResults.push(friend.get('follower'));
        }
      }
      return callback(error, newResults);
    });
  };

  exports.checkIfFriend = function(param, callback) {
    return userDao.checkIfFriend(param, function(error, result) {
      return callback(error, result);
    });
  };

  exports.queryMyCircles = function(param, callback) {
    return userDao.queryMyCircles(param, function(error, results) {
      return callback(error, results);
    });
  };

  exports.queryMyFavorites = function(param, callback) {
    return userDao.queryMyFavorites(param, function(error, results) {
      return callback(error, results);
    });
  };

  exports.queryMyAlbum = function(param, callback) {
    return userDao.queryMyAlbum(param, function(error, results) {
      return callback(error, results);
    });
  };

  exports.queryHisAlbum = function(param, callback) {
    return userDao.queryHisAlbum(param, function(error, results) {
      return callback(error, results);
    });
  };

  exports.queryHisAlbumLast = function(param, callback) {
    return userDao.queryHisAlbumLast(param, function(error, results) {
      return callback(error, results);
    });
  };

}).call(this);
