#当超时则释放连接
#最大连接数
#超时时间
release = (client) ->
  pool.release client
  return
config = require("../config/config")
log4js = require("log4js")
logger = log4js.getLogger(__filename)
poolModule = require("generic-pool")
pool = poolModule.Pool(
  name: "redis"
  create: (callback) ->
    client = require("redis").createClient(config.redisPort, config.redisHost)
    callback null, client
    return

  destroy: (client) ->
    client.quit()
    return

  max: 10
  idleTimeoutMillis: 30000
  log: true
)
module.exports = (callback) ->
  pool.acquire (err, client) ->
    logger.error "[" + __function + ":" + __line + "] " + err  if err
    client.end = ->
      release client
      return

    callback err, client
    return

  return
