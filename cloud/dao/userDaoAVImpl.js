// Generated by CoffeeScript 1.8.0
(function() {
  var classMap, config, pageLimit, queryPublish;

  config = require("cloud/config/config");

  classMap = {};

  pageLimit = 1;

  exports.queryByParam = function(_class, param, callback, includes, selectKeys) {
    var Class, key, page, query, value, _i, _len;
    if (classMap[_class]) {
      Class = classMap[_class];
    } else {
      Class = AV.Object.extend(_class);
      classMap[_class] = Class;
    }
    query = new AV.Query(Class);
    for (key in param) {
      value = param[key];
      if ((key.indexOf('meta')) === 0) {
        continue;
      }
      query.equalTo(key, value);
    }
    if (includes) {
      for (_i = 0, _len = includes.length; _i < _len; _i++) {
        key = includes[_i];
        query.include(key);
      }
    }
    if (selectKeys) {
      query.select(selectKeys);
    }
    page = 0;
    if (param.page) {
      page = param.page;
    }
    if (!param.metaUnLimit) {
      query.limit(pageLimit);
      query.skip(page * pageLimit);
    }
    return query.find({
      success: function(results) {
        return callback(null, results);
      },
      error: function(error) {
        return callback(error, null);
      }
    });
  };

  exports.get = function(_class, id, callback) {
    var query;
    query = new AV.Query(AV.Object.extend(_class));
    return query.get(id, {
      success: function(classObject) {
        return callback(null, classObject);
      },
      error: function(classObject, error) {
        if (error) {
          console.error(error);
        }
        return callback(error, classObject);
      }
    });
  };

  exports.getAndInclude = function(_class, id, keys, callback) {
    var key, query, _i, _len;
    query = new AV.Query(AV.Object.extend(_class));
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      key = keys[_i];
      query.include(key);
    }
    return query.get(id, {
      success: function(classObject) {
        return callback(null, classObject);
      },
      error: function(classObject, error) {
        if (error) {
          console.error(error);
        }
        return callback(error, classObject);
      }
    });
  };

  exports.getObject = function(classObject, callback) {
    var query;
    query = new AV.Query(AV.Object.extend(classObject.className));
    return query.get(classObject.id, {
      success: function(classObject) {
        return callback(null, classObject);
      },
      error: function(classObject, error) {
        if (error) {
          console.error(error);
        }
        return callback(error, classObject);
      }
    });
  };

  exports.save = function(toSave, callback) {
    return toSave.save(null, {
      success: function(toSave) {
        return callback(null, toSave);
      },
      error: function(toSave, error) {
        return callback(error, toSave);
      }
    });
  };

  exports["delete"] = function(toSave, callback) {
    return toSave.destroy({
      success: function(toSave) {
        return callback(null, toSave);
      },
      error: function(toSave, error) {
        return callback(error, toSave);
      }
    });
  };

  exports.insert = function(_class, param, callback) {
    var classObject, key, value;
    classObject = AV.Object["new"](_class);
    for (key in param) {
      value = param[key];
      classObject.set(key, value);
    }
    return classObject.save(null, {
      success: function(classObject) {
        return callback(null, classObject);
      },
      error: function(classObject, error) {
        return callback(error, classObject);
      }
    });
  };

  queryPublish = function(param, orderby, callback) {
    var cql, cqlParams, page;
    cql = 'select include author.avatar, include author.nickname, * from Publish where ';
    cql += 'publishType = ?';
    cqlParams = [param.publishType];
    if (param.publishType === '2') {
      cql += " and (author = (select follower from _Follower where user = pointer('_User', ?)) or author = pointer('_User', ?))";
      cqlParams.push(param.user.id);
      cqlParams.push(param.user.id);
    }
    page = 0;
    if (param.page) {
      page = param.page;
    }
    cql += ' limit ?,?';
    cqlParams.push(page * pageLimit);
    cqlParams.push(pageLimit);
    cql += ' ' + orderby;
    return AV.Query.doCloudQuery(cql, cqlParams, {
      success: function(result) {
        return callback(null, result.results);
      },
      error: function(error) {
        return callback(error, null);
      }
    });
  };

  exports.queryLatestPublish = function(param, callback) {
    return queryPublish(param, 'order by createdAt desc', callback);
  };

  exports.queryHotestPublish = function(param, callback) {
    return queryPublish(param, 'order by likeCount desc', callback);
  };

  exports.queryCommentsByPost = function(param, callback) {
    var Class, page, query, _class;
    _class = 'Comment';
    if (classMap[_class]) {
      Class = classMap[_class];
    } else {
      Class = AV.Object.extend(_class);
      classMap[_class] = Class;
    }
    query = new AV.Query(Class);
    query.include('author');
    query.select(['content', 'author.avatar', 'author.nickname', 'favoriteCount', 'likeCount']);
    query.equalTo('post', param.post);
    query.descending('createdAt');
    page = 0;
    if (param.page) {
      page = param.page;
    }
    query.limit(pageLimit);
    query.skip(page * pageLimit);
    return query.find({
      success: function(results) {
        return callback(null, results);
      },
      error: function(error) {
        return callback(error, null);
      }
    });
  };

  exports.queryFavorites = function(param, callback) {
    var Class, query, _class;
    _class = 'Favorite';
    if (classMap[_class]) {
      Class = classMap[_class];
    } else {
      Class = AV.Object.extend(_class);
      classMap[_class] = Class;
    }
    query = new AV.Query(Class);
    query.equalTo('author', param.user);
    return query.find({
      success: function(results) {
        return callback(null, results);
      },
      error: function(error) {
        return callback(error, null);
      }
    });
  };

  exports.queryFriends = function(param, callback) {
    var cql, cqlParams;
    cql = "select include follower.avatar, include follower.username, include follower.nickname, include follower.desc from _Follower where user = pointer('_User', ?) and follower = (select user from _Follower where follower = pointer('_User', ?))";
    cqlParams = [param.user.id, param.user.id];
    return AV.Query.doCloudQuery(cql, cqlParams, {
      success: function(result) {
        return callback(null, result.results);
      },
      error: function(error) {
        return callback(error, null);
      }
    });
  };

}).call(this);
