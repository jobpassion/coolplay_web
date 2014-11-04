# Use AV.Cloud.define to define as many cloud functions as you want.
# For example:
config = require "cloud/config/config"
userService = require 'cloud/service/userService'
AV.Cloud.define "hello", (request, response) ->
  response.success "Hello world!2"
  return
AV.Cloud.define "register", (request, response) ->
  response.success "success"
AV.Cloud.define "addToLike", (request, response) ->
  currentUser = AV.User.current()
  userService.addToLike currentUser, request.params.post, (error, result)->
    response.success result
AV.Cloud.define "addToFavorite", (request, response) ->
  currentUser = AV.User.current()
  userService.addToFavorite currentUser, request.params.post, (error, result)->
    response.success result
AV.Cloud.define "queryLatestPublish", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryLatestPublish request.params, (error, results)->
    response.success results
AV.Cloud.define "queryHotestPublish", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryHotestPublish request.params, (error, results)->
    response.success results
AV.Cloud.define "queryCommentsByPost", (request, response) ->
  currentUser = AV.User.current()
  request.params.post = userService.constructAVObject 'Publish', request.params.post
  request.params.user = currentUser
  userService.queryCommentsByPost request.params, (error, results)->
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