randomToken = ->
  crypto.randomBytes(20).toString "hex"
userDao = require(ROOT + "dao/userDao")
dictionary = require(ROOT + "config/dictionary")
crypto = require("crypto")
redisHelper = require(ROOT + "dao/redisHelper")
util = require(ROOT + "util/util")
async = require("async")

exports.register = (user, callback) ->
  #if not user.loginName or not user.password
  #  callback
  #    errCode: 2
  #    msg: dictionary.errCode[2]
  #  , false
  #  return
  #loginName = user.loginName
  userDao.queryByName loginName, (results) ->
    if results and results.length > 0
      callback
        errCode: 1
        msg: dictionary.errCode[1]
      , false
    else
      user.accessToken = randomToken()
      redisHelper.redis (err, client) ->
        client.set "user-token-" + user.loginName, user.accessToken
        return

      userDao.insert user
      callback user, true
    return

  return

exports.login = (user, callback) ->
  if not user.loginName or not user.password
    callback
      errCode: 2
      msg: dictionary.errCode[2]
    , false
    return
  loginName = user.loginName
  userDao.queryByName loginName, (results) ->
    if results and results.length > 0
      if user.password is results[0].password
        user.accessToken = randomToken
        redisHelper.redis (err, client) ->
          client.set "user-token-" + user.loginName, user.accessToken
          return

        callback user, true
      else
        callback
          errCode: 4
          msg: dictionary.errCode[4]
        , false
    else
      callback
        errCode: 3
        msg: dictionary.errCode[3]
      , false
    return

  return

exports.thirdLogin = (user, callback) ->
  unless user.nickname
    callback
      errCode: 2
      msg: dictionary.errCode[2]
    , false
    return
  loginName = user.loginName
  userDao.queryByParams
    thirdLogin: user.thirdLogin
    openId: user.openId
  , (results) ->
    if results and results.length > 0
      callback results[0], true
    else
      user.password = randomToken()
      async.waterfall [
        (next) ->
          userDao.insert user, (results) ->
            user.id = results.insertId
            next()
            return
        (next) ->
          userDao.registXMPP user, (results) ->
            next user, true
      ], callback
    return

  return

exports.addUserAction = (userAction, callback) ->
  userDao.insertUserAction userAction, util.resultHandle(callback, 5)
  return

exports.queryUserFavorites = (params, callback) ->
  params.type = 1
  userDao.queryUserAction params, util.resultHandle(callback, 5)
  return

exports.queryUserFavorite = (params, callback) ->
  params.type = 1
  userDao.queryUserAction params, util.resultHandle(callback, 5)
  return

exports.queryUserLike = (params, callback) ->
  params.type = 2
  userDao.queryUserAction params, util.resultHandle(callback, 5)
  return
exports.bindWeibo = (user, authData) ->
  f
