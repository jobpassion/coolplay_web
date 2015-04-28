config =
  impl: 'AVOS'
  dbHost: "mysql.cfp3qdjt6nej.ap-northeast-1.rds.amazonaws.com"
  dbUser: "awsuser"
  dbPassword: "261103692"
  
  #dbHost:'localhost',
  #dbUser:'root',
  #dbPassword:'root',
  dbDatabase: "webapp"
  
  #,redisHost:'localhost'
  redisHost: "awsc.droyyu.0001.apne1.cache.amazonaws.com"
  redisPort: "6379"
  solr: 
    host: 'solr-fanhua.rhcloud.com'
    port: ''
    core: 'coolweb_collection'
    path: '/'
  #local:true
log4js = require("log4js")
log4js.configure appenders: [
  {
    type: "logLevelFilter"
    level: "INFO"
    appender:
      type: "console"
      level: "error"
  }
  {
    type: "logLevelFilter"
    level: "INFO"
    appender:
      type: "dateFile"
      filename: "logs/logs.log"
      pattern: "-yyyy-MM-dd"
      maxLogSize: 1024
      alwaysIncludePattern: true
      backups: 5
  }
]

#,replaceConsole: true
GLOBAL.ROOT = __dirname + "/../"
module.exports = config
config.setAV = (_AV)->
  GLOBAL.AV = _AV
Object.defineProperty global, "__stack",
  get: ->
    orig = Error.prepareStackTrace
    Error.prepareStackTrace = (_, stack) ->
      stack

    err = new Error
    Error.captureStackTrace err, arguments_.callee
    stack = err.stack
    Error.prepareStackTrace = orig
    stack

Object.defineProperty global, "__line",
  get: ->
    return 0;
    __stack[1].getLineNumber()

Object.defineProperty global, "__function",
  get: ->
    return 'none'
    __stack[1].getFunctionName()

