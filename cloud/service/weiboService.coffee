config = require "cloud/config/config"
exports.searchNickname = (param, callback)->
  AV.Cloud.httpRequest
    url:'https://api.weibo.com/2/users/show.json'
    params:
      access_token:param.accessToken
      screen_name:param.who
    success:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      callback null, responseObject
    error:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      callback responseObject
exports.searchUID = (param, callback)->
  AV.Cloud.httpRequest
    url:'https://api.weibo.com/2/users/show.json'
    params:
      access_token:param.accessToken
      uid:param.who
    success:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      callback null, responseObject
    error:(httpResponse)->
      responseText = httpResponse.text
      responseObject = JSON.parse(responseText)
      callback responseObject
exports.searchWeibo = (param, callback)->
  exports.searchNickname
    accessToken:param.accessToken
    who:param.who
  , (error, result)->
    if !error
      callback null, result
    else
      exports.searchUID
        accessToken:param.accessToken
        who:param.who
      , (error, result)->
        if !error
          callback null, result
        else
          callback error, null
