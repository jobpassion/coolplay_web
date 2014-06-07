var config = {
    dbHost:'mysql.cfp3qdjt6nej.ap-northeast-1.rds.amazonaws.com',
    dbUser:'awsuser',
    dbPassword:'261103692',
    //dbHost:'localhost',
    //dbUser:'root',
    //dbPassword:'root',
    dbDatabase:'webapp'
    //,redisHost:'localhost'
    ,redisHost:'awsc.droyyu.0001.apne1.cache.amazonaws.com'
    ,redisPort:'6379'
    //,local:true
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
                    "pattern": "-yyyy-MM-dd",
                    "maxLogSize": 1024,
                    "alwaysIncludePattern": true,
                    "backups": 5

                }
        }
    ]
//,replaceConsole: true

});
GLOBAL.ROOT = __dirname + '/../';

module.exports = config;


Object.defineProperty(global, '__stack', {
get: function() {
        var orig = Error.prepareStackTrace;
        Error.prepareStackTrace = function(_, stack) {
            return stack;
        };
        var err = new Error;
        Error.captureStackTrace(err, arguments.callee);
        var stack = err.stack;
        Error.prepareStackTrace = orig;
        return stack;
    }
});

Object.defineProperty(global, '__line', {
get: function() {
        return __stack[1].getLineNumber();
    }
});

Object.defineProperty(global, '__function', {
get: function() {
        return __stack[1].getFunctionName();
    }
});
