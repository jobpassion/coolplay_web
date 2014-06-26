daoHelper = require("./daoHelper")
exports.insert = (businessImage, callback) ->
  daoHelper.sql "insert into businessImage set ?", businessImage, callback
  return
