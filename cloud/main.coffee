# Use AV.Cloud.define to define as many cloud functions as you want.
# For example:
config = require "cloud/config/config"
userService = require 'cloud/service/userService'
require 'cloud/hook'
AV.Cloud.define "hello", (request, response) ->
  response.success "Hello world!2"
  return
AV.Cloud.define "register", (request, response) ->
  response.success "success"
AV.Cloud.define "addToLike", (request, response) ->
  currentUser = AV.User.current()
  userService.addToLike currentUser, request.params.post, (error, result)->
    response.success result

AV.Cloud.define "removeToLike", (request, response) ->
  userService.removeToLike request.user, request.params.post, (error, result)->
    response.success result

AV.Cloud.define "addToFavorite", (request, response) ->
  currentUser = AV.User.current()
  userService.addToFavorite currentUser, request.params.post, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "removeToFavorite", (request, response) ->
  userService.constructAVObject 'Publish', request.params.post
  userService.removeToFavorite request.user, request.params.post, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "queryLatestPublish", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryLatestPublish request.params, (error, results)->
    response.success userService.recursiveToJson results
AV.Cloud.define "queryHotestPublish", (request, response) ->
  currentUser = AV.User.current()
  console.log 123
  request.params.user = currentUser
  userService.queryHotestPublish request.params, (error, results)->
    response.success userService.recursiveToJson results
AV.Cloud.define "queryCircleDetail", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryCircleDetail request.params, (error, results)->
    response.success userService.recursiveToJson results
AV.Cloud.define "queryCommentsByPost", (request, response) ->
  currentUser = AV.User.current()
  request.params.post = userService.constructAVObject 'Publish', request.params.post
  request.params.user = currentUser
  userService.queryCommentsByPost request.params, (error, results)->
    #console.log userService.recursiveToJson (results[0])
    #results = userService.recursiveToJson results
    response.success results
AV.Cloud.define "queryFavorites", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryFavorites request.params, (error, results)->
    response.success results
AV.Cloud.define "queryLikes", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryLikes request.params, (error, results)->
    response.success results
AV.Cloud.define "addCommentForPost", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  request.params.post = userService.constructAVObject 'Publish', request.params.post
  userService.addCommentForPost request.params, (error, results)->
    response.success results
AV.Cloud.define "deleteContact", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.deleteContact request.params, (error, result)->
    response.success result
AV.Cloud.define "queryFriends", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryFriends request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "checkIfFriend", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.checkIfFriend request.params, (error, result)->
    response.success result
AV.Cloud.define "queryMyCircles", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryMyCircles request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "queryMyFavorites", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryMyFavorites request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "queryMyAlbum", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryMyAlbum request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "queryHisAlbum", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryHisAlbum request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "queryHisAlbumLast", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryHisAlbumLast request.params, (error, result)->
    response.success userService.recursiveToJson result
AV.Cloud.define "guessIt", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.guessIt request.params, (error, result)->
    response.success userService.recursiveToJson result
