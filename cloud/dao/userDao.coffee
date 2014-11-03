config = require "cloud/config/config"

if config.impl == 'AVOS'
  userDao = require config.ROOT + 'dao/userDaoAVImpl'
else
  userDao = require config.ROOT + 'dao/userDaoImpl'
module.exports = userDao
