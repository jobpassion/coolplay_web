// Generated by CoffeeScript 1.8.0
(function() {
  var config, log4js;

  config = {
    impl: 'AVOS',
    dbHost: "mysql.cfp3qdjt6nej.ap-northeast-1.rds.amazonaws.com",
    dbUser: "awsuser",
    dbPassword: "261103692",
    dbDatabase: "webapp",
    redisHost: "awsc.droyyu.0001.apne1.cache.amazonaws.com",
    redisPort: "6379",
    solr: {
      host: 'solr-fanhua.rhcloud.com',
      port: '',
      core: 'coolweb_collection',
      path: '/'
    }
  };

  log4js = require("log4js");

  log4js.configure({
    appenders: [
      {
        type: "logLevelFilter",
        level: "INFO",
        appender: {
          type: "console",
          level: "error"
        }
      }, {
        type: "logLevelFilter",
        level: "INFO",
        appender: {
          type: "dateFile",
          filename: "logs/logs.log",
          pattern: "-yyyy-MM-dd",
          maxLogSize: 1024,
          alwaysIncludePattern: true,
          backups: 5
        }
      }
    ]
  });

  config.ROOT = "cloud/";

  module.exports = config;

}).call(this);
