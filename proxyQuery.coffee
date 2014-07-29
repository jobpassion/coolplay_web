proxy = []
block = false
blockingItems = []
requesting = []
cancelItems = []

headers =
  Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  "Accept-Encoding": ""
  "Accept-Language": "zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4"
  "Cache-Control": "max-age=0"
  "Proxy-Connection":"keep-alive"
  Host: "www.dianping.com"
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"
  Cookie: 'HOENIX_ID=0a01678e-1477d29110e-8b39ff; _hc.v="\"70d31d59-9e4d-42b9-a69d-6d96e2c681b3.1406553963\""; is=06867943003; ano=NdZNoPOqzwEkAAAAYTNlMjllN2UtNzVlOC00OTJiLWI0YWItNzE4NTdmMDNkODAwr15ZR6YcrbRR7S2xpoAhZkVHDns1; sid=purr2bv4w22zkhipq222twrh; m_rs=a3f9f38a-fa85-471d-9840-55c55daea437; abtest="51,131\|48,124\|52,133\|47,122\|44,107\|45,115"; __utma=1.2145327365.1406559703.1406566622.1406566622.75; __utmc=1; __utmz=1.1406566458.67.2.utmcsr=dianping.com|utmccn=(referral)|utmcmd=referral|utmcct=/search/category/1/10/x2y3; ab=; s_ViewType=1; JSESSIONID=6DB428680FDBFE14E26C268ADACD2D79; aburl=1; cy=1; cye=shanghai; lb.dp=184615178.20480.0000'
options =
  timeout: 10000
  headers: headers



currentProxy = null
updateProxy = ->
  if currentProxy
    err = 
      value: currentProxy
      type: 'proxy'
    daoHelper.sql 'insert into error set ?', err, null
    currentProxy = null

  if proxy.length > 0
    p = proxy.pop()
    for ep in errorProxy
      if p==ep.value
        updateProxy()
        return
    currentProxy = p
    logger.info "[" + __function + ":" + __line + "] proxy length " + proxy.length
    block = false
  else
    logger.info "[" + __function + ":" + __line + "] start query new proxies"
    request
      url: "http://www.site-digger.com/html/articles/20110516/proxieslist.html"
      timeout: 10000
    , (error, response, body) ->
      logger.error error  if error
      logger.info "[" + __function + ":" + __line + "]  queried new proxies"
      re = /<td>([\d.:]*)<\/td>/g
      matches = undefined
      proxy = []
      while matches = re.exec(body)
        logger.info matches[1]
        proxy.push matches[1]
      block = false
      return

  return

#updateProxy();
intervalQuery = ->
  return  if blockingItems.length == 0
  obj = blockingItems.pop()
  query obj.url, obj.callback
  return
query = (url, callback) ->
  obj =
    url: url
    callback: callback
  if requesting.length > 3
    blockingItems.push obj
    return

  if block
    blockingItems.push obj
    return
  if proxy.length == 0
    block = true
    blockingItems.push obj
    updateProxy()
    return
  requesting.push obj
  options.proxy = "http://" + proxy[proxy.length - 1]
  options.url = url
  logger.info "[" + __function + ":" + __line + "] " + url
  request options, (error, response, body) ->
    for i of requesting
      requesting.splice i, 1  if obj == requesting[i]
    
    #if(error){
    #	logger.error('[' + __function + ':' + __line + '] ' + error);
    #	blockingItems.push(obj);
    #	return;
    #}
    idx = cancelItems.indexOf(obj)
    if idx > -1
      blockingItems.push obj
      cancelItems.splice idx, 1
      return
    if error or not response? or 403 == response.statusCode
      logger.error "[" + __function + ":" + __line + "] " + error  if error
      block = true
      blockingItems.push obj
      for i of requesting
        continue  if requesting[i] == obj
        cancelItems.push requesting[i]
      requesting = []
      updateProxy()
      return
    callback error, response, body
    return

  return
request = require("request")
require "./config/config"
logger = require("log4js").getLogger(__filename)
daoHelper = require './dao/daoHelper'
setInterval (->
  intervalQuery()
  return
), 30
errorProxy = []
daoHelper.sql "select * from error where type = 'proxy'", null, (result, err)->
  errorProxy = result

exports.query = query
