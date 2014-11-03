config = require "cloud/config/config"
randomToken = ->
  crypto.randomBytes(20).toString "hex"
userDao = require(config.ROOT + "dao/userDao")
async = require("async")

classMap = {}
exports.addToLike = (user, post, callback) ->
  publish = AV.Object.new 'Comment'
  publish.set 'objectId', post
  userDao.queryByParam 'Like',
    author:user
    post:publish
    ,(error, results)->
      if error
        callback error,null
      else
        if results.length > 0
          callback null, 0#已经赞过
        else
          userDao.insert 'Like', 
            author:user
            post:publish
            ,(error, result)->
              if !error
                callback null, 1#成功赞
