config = require "cloud/config/config"
classMap = {}
exports.queryByParam = (_class, param, callback) ->
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  for key,value of param
    query.equalTo key, value
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
  query.equalTo 'publishType', param.publishType
  query.addDescending 'createdAt'
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null
exports.queryLatestPublish = (param, callback) ->
  _class = 'Publish'
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  query.include 'author'
  query.equalTo 'publishType', param.publishType
  query.addDescending 'createdAt'
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
  query.equalTo 'publishType', param.publishType
  query.addDescending 'likeCount'
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
  query.equalTo 'post', param.post
  query.addDescending 'createdAt'
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
  query.find
    success:(results)->
      callback null, results
    error:(error)->
      callback error, null