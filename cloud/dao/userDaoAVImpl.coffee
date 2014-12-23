config = require "cloud/config/config"
classMap = {}
pageLimit = 1
exports.queryByParam = (_class, param, callback, includes, selectKeys) ->
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  for key,value of param
    if key.indexOf 'meta' == 0
      continue
    query.equalTo key, value
  if includes
    for key in includes
      query.include key
  if selectKeys
    query.select selectKeys
  page = 0
  if param.page
    page = param.page
  if !param.metaUnLimit
    query.limit pageLimit
    query.skip page*pageLimit
  
  query.find
    success:(results)->
      callback null,results
    error:(error)->
      callback error,null
exports.get = (_class, id, callback)->
  query = new AV.Query AV.Object.extend _class
  query.get id, 
    success:(classObject)->
      callback null, classObject
    error:(classObject, error)->
      if error
        console.error error
      callback error, classObject
exports.getAndInclude = (_class, id,keys, callback)->
  query = new AV.Query AV.Object.extend _class
  for key in keys
    query.include key
  query.get id, 
    success:(classObject)->
      callback null, classObject
    error:(classObject, error)->
      if error
        console.error error
      callback error, classObject
exports.getObject = (classObject, callback)->
  query = new AV.Query AV.Object.extend classObject.className
  query.get classObject.id, 
    success:(classObject)->
      callback null, classObject
    error:(classObject, error)->
      if error
        console.error error
      callback error, classObject

exports.save = (toSave, callback)->
  toSave.save null, 
    success:(toSave)->
      callback null, toSave
    error:(toSave, error)->
      callback error, toSave
exports.delete = (toSave, callback)->
  toSave.destroy 
    success:(toSave)->
      callback null, toSave
    error:(toSave, error)->
      callback error, toSave
exports.insert = (_class, param, callback)->
  classObject = AV.Object.new _class
  for key,value of param
    classObject.set key, value
  classObject.save null, 
    success:(classObject)->
      #console.log classObject
      callback null, classObject
    error:(classObject, error)->
      #console.log error
      callback error, classObject
exports.queryLatestPublish = (param, callback) ->
  _class = 'Publish'
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  query.include 'author'
  query.select ['author.avatar', 'author.nickname', '*']
  query.equalTo 'publishType', param.publishType
  query.descending 'createdAt'
  page = 0
  if param.page
    page = param.page
  query.limit pageLimit
  query.skip page*pageLimit
  
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null
exports.queryHotestPublish = (param, callback) ->
  _class = 'Publish'
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  query.include 'author'
  query.select ['author.avatar', 'author.nickname', '*']
  query.equalTo 'publishType', param.publishType
  query.descending 'likeCount'
  page = 0
  if param.page
    page = param.page
  query.limit pageLimit
  query.skip page*pageLimit
  
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null
exports.queryCommentsByPost = (param, callback) ->
  _class = 'Comment'
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  query.include 'author'
  query.select ['content','author.avatar', 'author.nickname', 'favoriteCount', 'likeCount']
  query.equalTo 'post', param.post
  query.descending 'createdAt'
  page = 0
  if param.page
    page = param.page
  query.limit pageLimit
  query.skip page*pageLimit
  
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null
exports.queryFavorites = (param, callback) ->
  _class = 'Favorite'
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  query.equalTo 'author', param.user
  #page = 0
  #if param.page
  #  page = param.page
  #query.limit pageLimit
  #query.skip page*pageLimit
  
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null
