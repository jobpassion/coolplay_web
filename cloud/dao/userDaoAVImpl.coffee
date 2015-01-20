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
    if (key.indexOf 'meta') == 0
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
queryPublish = (param, orderby, callback)->
  cql =  'select include author.avatar, include author.nickname, * from Publish where '
  cql += 'publishType = ?'
  cqlParams = [param.publishType]
  if param.publishType ==  '2'
    cql += " and (author = (select follower from _Follower where user = pointer('_User', ?)) or author = pointer('_User', ?))"
    cqlParams.push param.user.id
    cqlParams.push param.user.id
  page = 0
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' ' + orderby
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.results
    error:(error)->
      callback error, null
exports.queryLatestPublish = (param, callback) ->
  queryPublish param, 'order by createdAt desc', callback
exports.queryHotestPublish = (param, callback) ->
  queryPublish param, 'order by favoriteCount,createdAt desc', callback
exports.queryCommentsByPost = (param, callback) ->
  cql = 'select content,author.avatar, author.nickname, favoriteCount, likeCount from Comment'
  cql += " where post = Pointer('Publish', ?)"
  cqlParams = [param.post.id]
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' order by createdAt desc'
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.results
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
exports.queryFriends = (param, callback)->
  cql = "select include follower.avatar, include follower.username, include follower.nickname, include follower.desc from _Follower where user = pointer('_User', ?) and follower = (select user from _Follower where follower = pointer('_User', ?))"
  cqlParams = [param.user.id, param.user.id]
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.results
    error:(error)->
      callback error, null
exports.checkIfFriend = (param, callback)->
  cql = "select count(*) from _Follower where (user = pointer('_User', ?) and follower = pointer('_User', ?)) or (user = pointer('_User', ?) and follower = pointer('_User', ?))"
  cqlParams = [param.user.id, param.friend, param.friend, param.user.id]
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.count
    error:(error)->
      callback error, null
exports.queryMyCircles = (param, callback)->
  cql =  'select include author.avatar, include author.nickname, include backImageStr, include shareCount, include content, include publishType, include favoriteCount, include commentCount from Publish where '
  cql += 'publishType = ?'
  cqlParams = [param.publishType]
  cql += " and author = pointer('_User', ?)"
  cqlParams.push param.user.id
  page = 0
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' order by createdAt desc'
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.results
    error:(error)->
      callback error, null
exports.queryMyFavorites = (param, callback)->
  cql =  'select include post.author.avatar, include post.author.nickname, include post.backImageStr, include post.shareCount, include post.content, include post.publishType, include post.favoriteCount, include post.commentCount from Favorite where '
  cql += "author = pointer('_User', ?)"
  cqlParams = [param.user.id]
  cql += ' and publishType = ?'
  cqlParams.push param.publishType
  page = 0
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' order by createdAt desc'
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      newResults = []
      for post in result.results
        newResults.push post.get 'post'
      callback null, newResults
    error:(error)->
      callback error, null
exports.queryMyAlbum = (param, callback)->
  cql =  'select filename from Album where '
  cql += "user = pointer('_User', ?)"
  cqlParams = [param.user.id]
  page = 0
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' order by createdAt desc'
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      callback null, result.results
    error:(error)->
      callback error, null
