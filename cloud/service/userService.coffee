config = require "cloud/config/config"
randomToken = ->
  crypto.randomBytes(20).toString "hex"
userDao = require(config.ROOT + "dao/userDao")
weiboService = require(config.ROOT + "service/weiboService")
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
                  comment.set 'favorite', true
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
                #userDao.get 'Publish', post, (error, publish)->
                userDao.getAndInclude 'Publish', post, ['author'], (error, publish)->
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
            #userDao.get 'Publish', post, (error, result)->
            userDao.getAndInclude 'Publish', post, ['author'], (error, result)->
              callback null, 
                object:result
                result:1
        else
          callback null, 
            result:0
exports.queryLatestPublish = (param, callback) ->
  if param.publishType == '2' && !param.user
    callback null, []
  userDao.queryLatestPublish param, (error, results1)->
    for post in results1
      post.set 'author',simpleUser post.get 'author'
    if param.user
      queryGuess results1, param.user, (error, results1)->
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
      
queryGuess = (posts, user, callback)->
  anonymousPosts = {}
  for post in posts
    if 1 == post.get('anonymous')
      anonymousPosts[post.id] = post
  userDao.queryGuess anonymousPosts, user, (error, results)->
    for result in results
      anonymousPosts[(result.get 'post').id].set "guessCount", result.get 'count'
      anonymousPosts[(result.get 'post').id].set "guessRight", result.get 'right'
    callback error, posts
exports.queryHotestPublish = (param, callback) ->
  userDao.queryHotestPublish param, (error, results1)->
    for post in results1
      post.set 'author',simpleUser post.get 'author'
    if param.user
      queryGuess results1, param.user, (error, results1)->
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
  paramCopy = {metaUnLimit:true}
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
    callback error, 1
recursiveToJson = (obj)->
  if !obj
    return obj
  if Array.isArray obj
    for i of obj
      obj[i] = recursiveToJson obj[i]
  else
    if obj.toJSON
      for key,value of obj.attributes
        obj.set key, recursiveToJson value
      obj = obj.toJSON()
    else if obj.thumbnailURL
      obj = 
        name:obj.name()
        metaData:obj.metaData()
        url:obj.url()
        size:obj.size()
    else
      for key,value of obj
        if value && value.toJSON
          obj[key]=recursiveToJson value
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
    
exports.queryCircleDetail = (param, callback) ->
  userDao.queryByParam 'Publish', 
    objectId:param.post
  , (error, results)->
    if !error && results.length > 0
      post = results[0]
      param.post = post
      exports.queryCommentsByPost param, (error, results)->
        post.set 'comments', results
        if param.user
          userDao.queryByParam 'Favorite', 
            author:param.user
            post:param.post
          , (error, results)->
            if results.length >0
              post.set 'favorite', true
            if (post.get 'anonymous') == 1
              userDao.queryByParam 'GuessIt',
                user:param.user
                post:param.post
              , (error, results)->
                if results && results.length > 0
                  post.set 'guessCount', results[0].get 'count'
                  post.set 'guessRight', results[0].get 'right'
                else
                  post.set 'guessCount', 0
                  post.set 'guessRight', false
                callback error, post
            else
              callback error, post
        else
          callback error, post
  , ['author'], ['author.nickname', 'author.avatar', 'backImageStr', 'shareCount', 'content', 'favoriteCount', 'commentCount', '*']
exports.queryFriends = (param, callback)->
  userDao.queryFriends param, (error, results)->
    newResults = []
    if !error
      for friend in results
        newResults.push friend.get 'follower'
    callback error, newResults
exports.checkIfFriend = (param, callback)->
  userDao.checkIfFriend param, (error, result)->
    callback error, result
exports.queryMyCircles = (param, callback)->
  userDao.queryMyCircles param, (error, results)->
    callback error, results
exports.queryMyFavorites = (param, callback)->
  userDao.queryMyFavorites param, (error, results)->
    callback error, results
exports.queryMyAlbum = (param, callback)->
  userDao.queryMyAlbum param, (error, results)->
    callback error, results
exports.queryHisAlbum = (param, callback)->
  userDao.queryHisAlbum param, (error, results)->
    callback error, results
exports.queryHisAlbumLast = (param, callback)->
  userDao.queryHisAlbumLast param, (error, results)->
    callback error, results
exports.guessIt = (param, callback)->
  userDao.queryByParam 'GuessIt',
    user:param.user
    post:constructAVObject('Publish', param.post)
  ,(error, results)->
    if results && results.length > 0
      guessIt = results[0]
      guessIt.set 'count', 1 + guessIt.get('count')
    else
      guessIt = AV.Object.new('GuessIt')
      guessIt.set 'user', param.user
      guessIt.set 'post', constructAVObject('Publish', param.post)
      guessIt.set 'count', 1
    userDao.save guessIt, (error, guessIt)->
      callback error, guessIt
    
exports.guessRight = (param, callback)->
  userDao.queryByParam 'GuessIt',
    user:param.user
    post:constructAVObject('Publish', param.post)
  ,(error, results)->
    if results && results.length > 0
      guessIt = results[0]
    else
      guessIt = AV.Object.new('GuessIt')
      guessIt.set 'user', param.user
      guessIt.set 'post', constructAVObject('Publish', param.post)
    guessIt.set 'right', true
    userDao.save guessIt, (error, guessIt)->
      callback error, guessIt
weiboFriends = (param, friends, callback)->
  AV.Cloud.httpRequest
    url:'https://api.weibo.com/2/friendships/friends.json'
    params:param
    success:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      if responseObject.users
        nextCursor = responseObject.next_cursor
        if nextCursor > 0
          param.cursor = nextCursor
          weiboFriends param, friends.concat(responseObject.users), callback
        else
          callback friends.concat(responseObject.users)
      else
        callback responseObject
    error:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      callback responseObject
exports.queryWeiboFriends = (param, callback)->
  if param.user.get 'authData'
    authData = param.user.get 'authData'
    if authData.weibo
      accessToken = authData.weibo.access_token
      uid = authData.weibo.uid
      weiboFriends
        access_token:accessToken
        uid:uid
        count:100
      ,[],(friends)->
        if friends.length
          userDao.queryAllUsersWithWeibo null,(error, results)->
            result = []
            weiboUserMap = {}
            for weiboUser in friends
              weiboUserMap[weiboUser.id] = weiboUser
            for u in results
              if weiboUserMap[(u.get 'authData').weibo.uid]
                result.push weiboUserMap[(u.get 'authData').weibo.uid]
              callback null, result
        else
          callback null, friends
    else
      callback '未绑定微博帐号',null
  else
    callback '未绑定微博帐号',null

exports.searchNewFriend = (param, callback)->
  if param.user.get 'authData'
    authData = param.user.get 'authData'
    if authData.weibo
      accessToken = authData.weibo.access_token
      weiboService.searchWeibo
        accessToken:accessToken
        who:param.who
      , (error, result)->
        if error
          callback error, null
        else
          if result
            userDao.queryUserWithWeibo
              uid:result.id
            ,(error, result1)->
              if result1
                result1 = recursiveToJson result1
                for key,value of result1
                  result[key] = value
                callback error, result
              else
                callback error, null
          else
            callback null, null
    else
      callback '未绑定微博帐号',null
  else
    callback '未绑定微博帐号',null
exports.queryContactFriends = (param, callback)->
  friends = param.contacts
  if friends.length
    userDao.queryAllUsersWithPhone null,(error, results)->
      result = []
      weiboUserMap = {}
      for friend in friends
        for phoneNum in friend.phoneNumbers
          weiboUserMap[phoneNum.replace(/[- ]*/g,'').replace(/\+86/,'')] = friend
      for u in results
        if weiboUserMap[(u.get 'mobilePhoneNumber')]
          u.set 'contactName', weiboUserMap[(u.get 'mobilePhoneNumber')].contactName
          result.push u
      callback null, result
  else
    callback null, friends
