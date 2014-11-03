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
AV.Cloud.define "queryLatestPublish", (request, response) ->
  currentUser = AV.User.current()
  request.params.user = currentUser
  userService.queryLatestPublish request.params, (error, results)->
    response.success results
