var config = {
    dbHost:'mysql.cfp3qdjt6nej.ap-northeast-1.rds.amazonaws.com',
    dbUser:'awsuser',
    dbPassword:'261103692',
    dbDatabase:'webapp',
}

var log4js = require('log4js');
log4js.configure({
    appenders: [
        {
            "type": "logLevelFilter",
            "level": "INFO",
            appender:
                { type: 'console' ,level:'error'}
        },
        {
            "type": "logLevelFilter",
            "level": "INFO",
            appender:
                { type: 'dateFile', filename: 'logs/logs.log', 
                    level:'ERROR',
                    "pattern": "-yyyy-MM-dd",
                    "maxLogSize": 1024,
                    "alwaysIncludePattern": true,
                    "backups": 5

                }
        }
    ],
replaceConsole: true

});
GLOBAL.ROOT = __dirname + '/../';

module.exports = config;
