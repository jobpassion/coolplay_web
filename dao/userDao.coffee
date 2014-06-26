daoHelper = require("./daoHelper")
exports.insert = (user, callback) ->
  daoHelper.sql "INSERT INTO user SET ?", user, callback
  return

exports.queryByName = (name, callback) ->
  daoHelper.sql "select * from user where loginName = ?", [name], callback
  return

exports.queryByname = (name, callback) ->
  daoHelper.sql "select * from user where name=?", name, callback
  return

exports.queryByParams = (params, callback) ->
  whereCause = ""
  for i of params
    whereCause += " and " + i + "='" + params[i] + "'"
  daoHelper.sql "select * from user where 1=1" + whereCause, null, callback
  return

exports.insertUserAction = (userAction, callback) ->
  daoHelper.sql "insert into userAction set ?", userAction, callback
  return

exports.queryUserAction = (params, callback) ->
  daoHelper.sql "select * from userAction where user=? and type=?", [
    params.user
    params.type
  ], callback
  return
