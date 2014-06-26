updateProxy = ->
  if proxy.length > 0
    proxy.pop()
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
  return  if blockingItems.length is 0
  obj = blockingItems.pop()
  query obj.url, obj.callback
  return
query = (url, callback) ->
  obj =
    url: url
    callback: callback

  if block
    blockingItems.push obj
    return
  if proxy.length is 0
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
      requesting.splice i, 1  if obj is requesting[i]
    
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
    if error or not response? or 403 is response.statusCode
      logger.error "[" + __function + ":" + __line + "] " + error  if error
      block = true
      blockingItems.push obj
      for i of requesting
        continue  if requesting[i] is obj
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
headers =
  Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  "Accept-Encoding": ""
  "Accept-Language": "zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4"
  "Cache-Control": "no-cache"
  Connection: "keep-alive"
  Host: "www.dianping.com"
  Pragma: "no-cache"
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"
  Cookie: "_hc.v=\"\"3b801394-1439-48f9-bc20-57d1b5a84d66.1398687560\"\"; tc=5; abtest=\"47,122|44,107|45,116\"; is=334431760877; ano=50qPs41kzwEkAAAAZDZjNzQ2OGYtZWM4Ni00OTllLWI1Y2QtZTg3YTc4NzRmYmFkEMAwn-18UdrOhDUEMB239uccdts1; sid=d5lk3z2oichkou55pxchgn45; PHOENIX_ID=0a010406-145af3c4836-315aa; JSESSIONID=C83F1032948A6ECB0BBB3C37A2EBBBF1; aburl=1; cy=5; cye=nanjing; __utma=1.284892197.1398687561.1398779639.1398813793.5; __utmb=1.57.10.1398813793; __utmc=1; __utmz=1.1398687561.1.1.utmcsr=google.com.hk|utmccn=(referral)|utmcmd=referral|utmcct=/; s_ViewType=1; ab=; lb.dp=1141113098.20480.0000"

options =
  timeout: 20000
  headers: headers

proxy = []
block = false
blockingItems = []
requesting = []
cancelItems = []
setInterval (->
  intervalQuery()
  return
), 3000
exports.query = query
