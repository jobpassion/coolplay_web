var config = {
    dbHost:'localhost',
    dbUser:'root',
    dbPassword:'root',
    dbDatabase:'test',
}

var log4js = require('log4js');
log4js.configure({
  appenders: [
    { type: 'console' },
    { type: 'file', filename: 'logs/logs.log'}
  ]
});
GLOBAL.ROOT = __dirname + '/../';

module.exports = config;
