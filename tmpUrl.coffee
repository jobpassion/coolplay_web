config = require "./config/config"
logger = require("log4js").getLogger(__filename)
daoHelper = require './dao/daoHelper'
proxyQuery = require("./proxyQuery")
env = require("jsdom").env
jquery = require("jquery")
S = require("string")


i = 0
intervalQuery = (quali)->
  logger.info "[" + __function + ":" + __line + "] thread:" + quali
  if i>1000 
    return
  tmpUrl = 
    url: 'http://www.dianping.com/search/category/2/10/x' + i + 'y' + ++i
  daoHelper.sql "update error set value = ? where type = 'current'", [i], null

  proxyQuery.query tmpUrl.url, (error, response, body) ->
    env body, (errors, window) ->
      try
        $ = jquery(window)
        a = $('.guide').find('.Color7').html()
        tmpUrl.count = a.substring(1, a.length - 1)
      catch e
        #console.log(body)
        err = 
          value: tmpUrl.url
        daoHelper.sql 'insert into error set ?', err, null
        intervalQuery quali
        window.close()
        return
      window.close()
      daoHelper.sql 'insert into tmpUrls set ?', tmpUrl, (result, err)->
        if err
          console.err err
        else
          console.log 'success ' + i
        setTimeout (->
          intervalQuery quali
          return
        ), 100
    
daoHelper.sql "select * from error where type = 'current'", null, (result, err)->
  i = result[0].value
  intervalQuery 1
  intervalQuery 2
  intervalQuery 3
