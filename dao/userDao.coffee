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

  daoHelper.sql "select t1.*, count(t2.id) reviewCount from business t1 left  join businessReview t2 on t1.id = t2.businessId where " + likeStr + " group by t1.id ", null, callback
exports.queryUserAction = (params, callback) ->
  daoHelper.sql "select a.user, b.* , count(t2.id) reviewCount  from userAction a left join business b on a.target = b.id 
 left join businessReview t2 on b.id = t2.businessId
  where a.user=? and a.type=? group by b.id", [
    params.user
    params.type
  ], callback
  return
