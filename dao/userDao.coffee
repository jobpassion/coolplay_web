config = require ROOT + "config/config"

if config.impl == 'AVOS'
  userDao = require ROOT + 'dao/userDaoAVImpl'
else
  userDao = require ROOT + 'dao/userDaoImpl'
module.exports = userDao
