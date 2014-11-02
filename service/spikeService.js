// Generated by CoffeeScript 1.8.0
(function() {
  var CronJob, addJob, addressReg, answersCache, cJob, fs, intervalPer100ms, listUsers, local, logger, multiline, properties, queryBySessionUser, querySessionCount, refreshBySessionUser, refreshSessionCount, request, requestionRegex, rl, submitBySessionUser, submitJob, tough, users, _addJob;

  local = require(ROOT + 'config/local.en');

  multiline = require('multiline');

  logger = require("log4js").getLogger(__filename);

  CronJob = require('cron').CronJob;

  request = require("request");

  tough = require('tough-cookie');

  properties = require('properties');

  rl = require(ROOT + 'service/stdInputService');

  fs = require('fs');

  rl = rl.rl;

  answersCache = {};

  properties.parse("spikeCache", {
    path: true
  }, function(error, obj) {
    if (error) {
      return console.error(error);
    }
    return answersCache = obj;
  });

  users = [
    {
      userName: 'ridk2020@163.com',
      loginToken: '__p__=508669b24f189e6d2df2395b52cd99a0b9f9c8656cac1e051a80a096294f09d2',
      jar: request.jar(),
      status: 0,
      sessions: []
    }, {
      userName: 'feng070900@163.com',
      loginToken: '__p__=fd548bbf72132ce8142f81f7e7366554cb123354e4dc1b863c07408d018cb2d1',
      jar: request.jar(),
      status: 0,
      sessions: []
    }, {
      userName: 'sasa4428@163.com',
      loginToken: '__p__=f1ea01f660a7e23ed07ee92af8c79c5923fe01b6952bdc027c9864d8074f1cd2',
      jar: request.jar(),
      status: 0,
      sessions: []
    }, {
      userName: 'dada3028@163.com',
      loginToken: '__p__=77c4b9865dfa1e1f2d8e496a56fee63d8dd9d0c0377c1ad8e6987cd2ec2b6b07',
      jar: request.jar(),
      status: 0,
      sessions: []
    }
  ];

  listUsers = function() {
    var user, _i, _len, _results;
    console.log(multiline(function() {

      /*
      id  userName  status
       */
    }));
    _results = [];
    for (_i = 0, _len = users.length; _i < _len; _i++) {
      user = users[_i];
      _results.push(console.log(multiline(function() {

        /*
        %s  %s  %s
         */
      }), _i, user.userName, user.status));
    }
    return _results;
  };

  requestionRegex = /onclick="refreshQue\(\);">(.*)<\/span>/;

  addJob = function(cmd) {
    var user, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = users.length; _i < _len; _i++) {
      user = users[_i];
      if (user.status === 1) {
        continue;
      }
      console.log(local.adding, user.userName);
      rl.question(local.ask_url + '\n', function(res) {
        user.status = 1;
        return user.url = res;
      });
      break;
    }
    return _results;
  };

  _addJob = function(url) {
    var user, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = users.length; _i < _len; _i++) {
      user = users[_i];
      if (user.status === 1) {
        continue;
      }
      console.log(local.adding, user.userName);
      user.status = 1;
      user.url = url;
      break;
    }
    return _results;
  };

  exports.process = function(cmd) {
    switch (cmd) {
      case local.list_users:
        return listUsers();
      case local.add_job:
        return addJob(cmd);
      case local.help:
        return console.log(local.welcome);
    }
  };

  exports.welcome = function() {
    return console.log(local.welcome, local.list_users, local.add_job, local.help);
  };

  refreshSessionCount = 0;

  querySessionCount = 0;

  refreshBySessionUser = function(session, user) {
    session.refreshing = 1;
    return request({
      url: 'http://www.600280.com/member/index',
      headers: {
        Cookie: user.loginToken,
        jar: session.jar
      }
    }, function(error, response, body) {
      var e;
      try {
        if (response.headers['set-cookie']) {
          session.jar.setCookieSync(response.headers['set-cookie'][0], 'http://www.600280.com');
          session.lastUpdate = new Date().getTime();
          session.refreshing = null;
          session.status = 1;
          logger.info('login ' + session.lastUpdate);
          refreshSessionCount++;
          return logger.info('refreshSessionCount:' + refreshSessionCount);
        }
      } catch (_error) {
        e = _error;
        console.error(user.userName);
        return console.error(e);
      }
    });
  };

  intervalPer100ms = setInterval(function() {
    var session, user, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = users.length; _i < _len; _i++) {
      user = users[_i];
      if (user.status === 1) {
        _results.push((function() {
          var _j, _len1, _ref, _results1;
          _ref = user.sessions;
          _results1 = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            session = _ref[_j];
            if (session.refreshing === 1) {
              continue;
            }
            if (!session.lastUpdate || new Date().getTime() - session.lastUpdate >= 20 * 60 * 1000) {
              refreshBySessionUser(session, user);
              break;
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }, 100);

  cJob = new CronJob('* * * * * *', function() {
    var a, session, user, _i, _len, _results;
    logger.info('cron per second excute');
    _results = [];
    for (_i = 0, _len = users.length; _i < _len; _i++) {
      user = users[_i];
      if (user.status === 1) {
        while (user.sessions.length < 50) {
          a = 1;
          session = {
            jar: request.jar()
          };
          user.sessions.push(session);
        }
        _results.push((function() {
          var _j, _len1, _ref, _results1;
          _ref = user.sessions;
          _results1 = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            session = _ref[_j];
            if (session.querying === 1) {
              continue;
            }
            if (session.status === 1) {
              cJob.stop();
              queryBySessionUser(session, user);
              break;
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }, null, true);

  addressReg = /userPostAddressList = .*"id":(.*),"userId/;

  queryBySessionUser = function(session, user) {
    session.querying = 1;
    return request({
      url: user.url,
      jar: session.jar
    }, function(error, response, body) {
      var answer, e, results;
      cJob.start();
      try {
        logger.info('query ' + session.lastUpdate);
        querySessionCount++;
        logger.info('querySessionCount:' + querySessionCount);
        session.querying = null;
        results = addressReg.exec(body);
        if (results) {
          session.addressIds = results[1];
        }
        results = requestionRegex.exec(body);
        session.status = 2;
        if (results) {
          answer = '';
          if (answersCache[results[1]]) {
            answer = answersCache[results[1]];
            return session.answer = answer;
          } else {
            cJob.stop();
            return rl.question(results[1] + '\n', function(res) {
              console.log(local.ok);
              answer = res;
              session.answer = answer;
              fs.appendFile('spikeCache', '\n' + results[1] + '=' + answer, function(err) {});
              return cJob.start();
            });
          }
        }
      } catch (_error) {
        e = _error;
      }
    });
  };

  submitJob = new CronJob('31 59 11 * * 5', function() {
    var inter;
    clearInterval(intervalPer100ms);
    cJob.stop();
    return inter = setInterval(function() {
      var b, session, user, _i, _len;
      b = false;
      for (_i = 0, _len = users.length; _i < _len; _i++) {
        user = users[_i];
        if (user.status !== 1 || user.sessions.length === 0) {
          continue;
        }
        while (user.sessions.length > 0) {
          session = user.sessions.shift();
          if (session.status !== 2) {
            continue;
          }
          submitBySessionUser(session, user);
          b = true;
          break;
        }
      }
      if (!b) {
        return clearInterval(inter);
      }
    }, 200);
  }, null, true);

  submitBySessionUser = function(session, user) {
    logger.info('submit :' + session.addressIds);
    return request.post({
      url: 'http://zf.600280.com//order/addSecKill',
      form: {
        verifyAns: session.answer,
        addressIds: session.addressIds,
        onlyFee: 0,
        remark: ''
      },
      jar: session.jar
    }, function(error, response, body) {
      if (error) {
        logger.error(error);
      }
      logger.info(body);
      if (body.indexOf('"result":"0"') !== -1 || body.indexOf("-1") !== -1 || body.indexOf("-2") !== -1) {
        logger.info(local.success + ':' + user.url);
        return user.status = 2;
      }
    });
  };

  _addJob('http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=184281');

  _addJob('http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=320190');

  _addJob('http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934');

  _addJob('http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934');

}).call(this);
