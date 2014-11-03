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
exports.addToFavorite = (user, post, callback) ->
  publish = AV.Object.new 'Publish'
  publish.set 'objectId', post
  userDao.queryByParam 'Favorite',
    author:user
    post:publish
    ,(error, results)->
      if error
        callback error,null
      else
        if results.length > 0
          callback null, 0#已经赞过
        else
          userDao.insert 'Favorite', 
            author:user
            post:publish
            ,(error, result)->
              if !error
                userDao.get 'Publish', post, (error, publish)->
                  publish.add 'favorites', result
                  userDao.save publish, (error, result)->
                    callback null, 1#成功赞
exports.queryLatestPublish = (param, callback) ->
  userDao.queryLatestPublish param, (error, results1)->
    if param.user
      userDao.queryFavorites param, (error, results)->
        favoriteMap = {}
        for favorite in results
          favoriteMap[(favorite.get 'post').id] = 1
        for post in results1
          if favoriteMap[post.id]
            post.set 'favorite', true
        callback error, results1
    else
      callback error, results1
          

