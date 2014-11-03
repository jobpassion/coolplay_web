// Generated by CoffeeScript 1.8.0
(function() {
  var classMap, config;

  config = require("cloud/config/config");

  classMap = {};

  exports.queryByParam = function(_class, param, callback) {
    var Class, key, query, value;
    if (classMap[_class]) {
      Class = classMap[_class];
    } else {
      Class = AV.Object.extend(_class);
      classMap[_class] = Class;
    }
    query = new AV.Query(Class);
    for (key in param) {
      value = param[key];
      query.equalTo(key, value);
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

  exports.queryLatestPublish = function(param, callback) {
    var Class, query, _class;
    _class = 'Publish';
    if (classMap[_class]) {
      Class = classMap[_class];
    } else {
      Class = AV.Object.extend(_class);
      classMap[_class] = Class;
    }
    query = new AV.Query(Class);
    query.include('author');
    query.equalTo('publishType', param.publishType);
    query.addDescending('createdAt');
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

}).call(this);
