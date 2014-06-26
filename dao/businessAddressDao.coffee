daoHelper = require("./daoHelper")
exports.insert = (businessAddress, callback) ->
  daoHelper.sql "insert into businessAddress set ?", businessAddress, callback
  return
