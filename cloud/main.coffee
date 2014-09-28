# Use AV.Cloud.define to define as many cloud functions as you want.
# For example:
config = require "../config/config"
userService = require ROOT + 'service/userService'
AV.Cloud.define "hello", (request, response) ->
  response.success "Hello world!"
  return
AV.Cloud.define "register", (request, response) ->
  response.success "success"
