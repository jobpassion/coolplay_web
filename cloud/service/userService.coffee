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
          callback null, 
            result:0
        else
          userDao.insert 'Like', 
            author:user
            post:publish
            ,(error, result)->
              if !error
                userDao.get 'Comment', post, (error, comment)->
                  comment.add 'likes', result
                  userDao.save comment, (error, result)->
                    comment.set 'like', true
                    callback null, 
                      object:comment
                      result:1

exports.removeToLike = (user, post, callback) ->
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
          like = results[0]
          userDao.delete like, (error, result)->
            userDao.get 'Comment', post, (error, result)->
              result.remove 'likes', like
              userDao.save result, (error, result1)->
                callback null, 
                  object:result
                  result:1
        else
          callback null, 
            result:0
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
          callback null, 
            result:0
        else
          userDao.insert 'Favorite', 
            author:user
            post:publish
            ,(error, result)->
              if !error
                userDao.get 'Publish', post, (error, publish)->
                  publish.add 'favorites', result
                  userDao.save publish, (error, result)->
                    publish.set 'favorite', true
                    callback null, 
                      object:publish
                      result:1
exports.removeToFavorite = (user, post, callback) ->
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
          favorite = results[0]
          userDao.delete favorite, (error, result)->
            userDao.get 'Publish', post, (error, result)->
              result.remove 'favorites', favorite
              userDao.save result, (error, result1)->
                callback null, 
                  object:result
                  result:1
        else
          callback null, 
            result:0
exports.queryLatestPublish = (param, callback) ->
  userDao.queryLatestPublish param, (error, results1)->
    for post in results1
      post.set 'author',simpleUser post.get 'author'
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
exports.queryHotestPublish = (param, callback) ->
  userDao.queryHotestPublish param, (error, results1)->
    for post in results1
      post.set 'author',simpleUser post.get 'author'
    if param.user
      queryFavorites param, (error, results)->
        favoriteMap = {}
        for favorite in results
          favoriteMap[(favorite.get 'post').id] = 1
        for post in results1
          if favoriteMap[post.id]
            post.set 'favorite', true
        callback error, results1
    else
      callback error, results1
exports.queryCommentsByPost = (param, callback) ->
  userDao.queryCommentsByPost param, (error, results1)->
    for post in results1
      post.set 'author',simpleUser post.get 'author'
    if param.user
      queryLikes 
        author:param.user
        post:param.post
      , (error, results)->
        favoriteMap = {}
        for favorite in results
          favoriteMap[(favorite.get 'post').id] = 1
        for post in results1
          if favoriteMap[post.id]
            post.set 'favorite', true
        callback error, results1
    else
      callback error, results1

queryLikes = (param, callback) ->
  paramCopy = {}
  if param.user
    paramCopy.user = param.user
  userDao.queryByParam 'Like', paramCopy, callback
exports.queryLikes = queryLikes
queryFavorites = (param, callback) ->
  if param.user
    userDao.queryFavorites param, callback
exports.queryFavorites = queryFavorites
constructAVObject = (_class, objectId)->
  avObject = AV.Object.new _class
  avObject.set 'objectId', objectId
  return avObject
exports.constructAVObject = constructAVObject

exports.addCommentForPost = (param, callback) ->
  comment = AV.Object.new 'Comment'
  comment.set 'content', param.content
  comment.set 'author', param.user
  comment.set 'post', param.post
  userDao.save comment, (error, comment)->
    post = param.post
    userDao.getObject post, (error, post)->
        post.add 'comments', comment
        userDao.save post, (error, post)->
          callback error, 1
      error:(classObject, error)->
recursiveToJson = (obj)->
  #obj = obj.toJSON()
  if Array.isArray obj
    for i in [0..obj.length - 1]
      obj[i] = recursiveToJson obj[i]
  else
    for key,value of obj.attributes
      if value.toJSON
        obj.set key, recursiveToJson value
    obj = obj.toJSON()
  return obj
exports.recursiveToJson = recursiveToJson
simpleUser = (user)->
  user = user.toJSON()
  interests:user.interests
  avatar:user.avatar
  objectId:user.objectId
  desc:user.desc
  nickname:user.nickname
exports.deleteContact = (param, callback) ->
  me = param.user
  him = param.him
  me.unfollow him, 
    success:()->
      himUser = new AV.User()
      himUser.set 'objectId', him
      himUser.fetch
        success:(himUser)->
          himUser.unfollow me.id, 
            success:()->
              callback null, true
            error:(error)->
              console.log 'error'
    error:(error)->
    
