daoHelper = require("./daoHelper")
exports.insert = (businessPromotion, callback) ->
  daoHelper.sql "insert into businessPromotion set ?", businessPromotion, callback
  return
