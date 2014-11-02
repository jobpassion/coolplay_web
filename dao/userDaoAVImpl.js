// Generated by CoffeeScript 1.8.0
(function() {
  var classMap;

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

}).call(this);
