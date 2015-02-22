config = require "cloud/config/config"
classMap = {}
pageLimit = 20
publishSelectKey = 'include author.avatar, include author.nickname, *'
exports.AVClass = (_class)->
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  return Class

exports.queryByParam = (_class, param, callback, includes, selectKeys) ->
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  for key,value of param
    if (key.indexOf 'meta') == 0 or key == 'last' or key == 'orderBy'
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
  if param.last
    query.lessThan 'objectId', param.last
  if param.orderBy
    param.orderBy query
  
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
  cql =  "select #{publishSelectKey} from Publish where "
  cql += 'publishType = ?'
  cqlParams = [param.publishType]
  if param.user && param.publishType ==  '2'
    cql += " and (author = (select follower from _Follower where user = pointer('_User', ?)) or author = pointer('_User', ?))"
    cqlParams.push param.user.id
    cqlParams.push param.user.id
  else if param.user && param.publishType == '1'
    cql += " and author not in (select follower from _Follower where user = pointer('_User', ?)) and author not in (select followee from _Followee where user = pointer('_User', ?))"
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
  cql = 'select content,include author.avatar, include author.nickname, favoriteCount, likeCount from Comment'
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
  cql =  "select #{publishSelectKey} from Publish where  1 != 0"
  cqlParams = []
  if param.publishType
    cql += ' and publishType = ?'
    cqlParams .push param.publishType
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
  cql =  'select include post.author.avatar, include post.author.nickname, include post.backImageStr, include post.shareCount, include post.content, include post.publishType, include post.favoriteCount, include post.commentCount, include post.anonymous, include post.anonymousNickname, include post.anonymousAvatar from Favorite where '
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
  cql =  'select filename, include file.name, include file.url, include file.metaData from Album where '
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

exports.queryHisAlbum = (param, callback)->
  cql =  'select filename, include file.name, include file.url, include file.metaData from Album where '
  cql += "user = pointer('_User', ?)"
  cqlParams = [param.him]
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
exports.queryHisAlbumLast = (param, callback)->
  cql =  'select filename, include file.name, include file.url, include file.metaData from Album where '
  cql += "user = pointer('_User', ?)"
  cqlParams = [param.him]
  cql += ' limit ?'
  cqlParams.push 1
  cql += ' order by createdAt desc'
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results && result.results.length > 0
        callback null, result.results[0]
      else
        callback null, null
    error:(error)->
      callback error, null
exports.queryGuess = (anonymousPosts, user, callback)->
  cql =  "select * from GuessIt where post in (pointer('Publish','111')"
  cqlParams = []
  for key,value of anonymousPosts
    cql += ", pointer('Publish',?)"
    cqlParams.push key
  cql += ')'
  cql += " and user = pointer('User', ?)"
  cqlParams.push user.id
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results
        callback null, result.results
    error:(error)->
      callback error, null
exports.queryAllUsersWithWeibo = (param, callback)->
  cql = 'select * from _User where authData.weibo is exists'
  cqlParams = []
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results
        callback null, result.results
      else
        callback null, null
    error:(error)->
      callback error, null
exports.queryUserWithWeibo = (param, callback)->
  cql = 'select * from _User where authData.weibo.uid = ?'
  cqlParams = ["" + param.uid + ""]
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results && result.results.length > 0
        callback null, result.results[0]
      else
        callback null, null
    error:(error)->
      callback error, null
exports.queryAllUsersWithPhone = (param, callback)->
  cql = 'select * from _User where mobilePhoneNumber is exists'
  cqlParams = []
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results
        callback null, result.results
      else
        callback null, null
    error:(error)->
      callback error, null
exports.queryHisTimeline = (param, callback)->
  cql = "select #{publishSelectKey} from Publish where author = pointer('_User', ?) and publishType = ?"
  cqlParams = [param.him, param.publishType]
  if '2' == param.publishType
    cql += " and (anonymous  = 0 or objectId in (select post.objectId from GuessIt where right = true and user = pointer('_User', ?)))"
    cqlParams.push param.user.id
  
  if param.last && '' != param.last
    cql += ' and objectId < ?'
    cqlParams.push param.last
  cql += ' limit ?'
  cqlParams.push pageLimit
  cql += ' order by createdAt desc'
  console.log cql
  console.log cqlParams
  AV.Query.doCloudQuery cql,cqlParams,
    success:(result)->
      if result && result.results && param.publishType == '2'
        for r in result.results
          r.set 'guessRight', true
      callback null, result.results
    error:(error)->
      callback error, null
