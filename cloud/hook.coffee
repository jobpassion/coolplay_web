config = require "cloud/config/config"
userDao = require(config.ROOT + "dao/userDao")
randomName = require 'chinese-random-name'
#userService = require 'cloud/service/userService'
#AV.Cloud.beforeSave 'FileUpload', (request)->
#  file = request.object
#  file = file.get 'data'
#  width = file.metaData().originWidth
#  height = file.metaData().originHeight
#  newSize = scale 
#    width:width
#    height:height, 150, 800
#  url = file.thumbnailURL newSize.width, newSize.height
#  console.log url
#  file.set 'thumbnail', url
#  
#scale = (size, width, height)->
#  oldWidth = size.width
#  oldHeight = size.height
#  scaleFactor = width / oldWidth
#  scaleFactor2 = height / oldHeight
#  if scaleFactor2 < scaleFactor
#    scaleFactor = scaleFactor2
#  width:Math.round oldWidth*scaleFactor
#  height:Math.round oldHeight*scaleFactor
#  

AV.Cloud.beforeSave 'Favorite', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'favoriteCount', 1
  userDao.save post, (error, result)->
    post.fetch
      success:(post)->
        favo.set 'publishType', post.get 'publishType'
        favo.save()
        response.success()
      error:(post, error)->
AV.Cloud.beforeDelete 'Favorite', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'favoriteCount', -1
  userDao.save post, (error, result)->
    response.success()
AV.Cloud.beforeSave 'Like', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'likeCount', 1
  userDao.save post, (error, result)->
    response.success()
AV.Cloud.beforeDelete 'Like', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'likeCount', -1
  userDao.save post, (error, result)->
    response.success()
AV.Cloud.beforeSave 'Comment', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'commentCount', 1
  userDao.save post, (error, result)->
    response.success()
AV.Cloud.beforeDelete 'Comment', (request, response)->
  favo = request.object
  post = favo.get 'post'
  post.increment 'commentCount', -1
  userDao.save post, (error, result)->
    response.success()
AV.Cloud.beforeSave 'Album', (request, response)->
  album = request.object
  userDao.queryByParam '_File', 
    name:album.get 'filename'
  , (error, results)->
    if !error && results.length > 0
      file = results[0]
      request.object.set 'file', file
      #album.set 'url', 'abc'
      response.success()
AV.Cloud.beforeSave 'Publish', (request, response)->
  post = request.object
  if 1 == post.get 'anonymous'
    post.set 'anonymousNickname', randomName.generate()
    userDao.queryByParam '_File', 
      name:'avatar_female_' + Math.floor(1 + Math.random() * 1578) + '.jpg'
    , (error, results)->
      if !error && results.length > 0
        file = results[0]
        post.set 'anonymousAvatar', file.get 'url'
        response.success()
  else
    response.success()
AV.Cloud.beforeSave '_User', (request, response)->
  post = request.object
  if post.get 'authData'
    authData = post.get 'authData'
    if authData.weibo
      post.set 'weibo', '1'
      response.success()
      return
  response.success()
AV.Cloud.afterUpdate '_User', (request)->
  post = request.object
  if post.get 'authData'
    authData = post.get 'authData'
    if authData.weibo
      post.set 'weibo', '1'
      userDao.save post, (error, result)->
        console.log 123
      return
