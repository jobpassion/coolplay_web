sql = (_sql, _args, callback) ->
  connection = pool.getConnection((err, connection) ->
    logger.error err  if err
    if err
      sql(_sql, _args, callback)
      return
    query = connection.query(_sql, _args, (err, result) ->
      logger.debug "sql executed"
      connection.release()
      logger.error err  if err
      if callback
        callback result, err
      else

      return
    )
    return
  )
  return
config = require("../config/config")
mysql = require("mysql")
log4js = require("log4js")
logger = log4js.getLogger(__filename)
pool = mysql.createPool(
  host: config.dbHost
  user: config.dbUser
  database: config.dbDatabase
  password: config.dbPassword
)
logger.debug "db initialized"

#logger.error(err);
exports.sql = sql
