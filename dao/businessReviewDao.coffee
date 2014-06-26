daoHelper = require("./daoHelper")
exports.insert = (businessReview, callback) ->
  daoHelper.sql "insert into businessReview set ?", businessReview, callback
  return
