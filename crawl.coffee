queryItem = (itemId) ->
  options =
    host: "nj.meituan.com"
    port: 80
    path: "/deal/" + itemId + ".html"
    method: "GET"

  console.log "crawling " + itemId
  request = http.request(options, (res) ->
    res.on "data", (data) ->
      res = sourceId: itemId
      #;
      re = console.log(data.toString())
      return

    return
  )
  request.end()
  return

#function proxiedQueryItem(itemId){
#	var options = {
#		//host: '111.1.60.210',
#		//port: 80,
#		//path: 'http://www.dianping.com/search/category/5/10/g25474p5',
#		host: 'www.dianping.com',
#		port: 80,
#		path: '/search/category/5/10/g25474p5',
#        headers:headers,
#		method: 'GET'
#	};
#
#	console.log("crawling " + itemId);
#	var request = http.request(options,function(res){
#		res.on('data',function(data){
#			var res = {sourceId:itemId};
#			var re = //;
#			console.log(data.toString());
#		});
#	});
#
#	request.end();
#}
proxiedQueryPage = (url, page) ->
  return  unless url
  
  #var options = {
  #	//host: '111.1.60.210',
  #	//port: 80,
  #	//path: 'http://www.dianping.com/search/category/5/10/g25474p5',
  #	host: 'www.dianping.com',
  #	port: 80,
  #	path: url,
  #    headers:headers,
  #	method: 'GET'config
  #};
  logger.info "crawling page " + url.url + " page index:" + page
  
  #var request = http.get(options,function(res){
  #        console.log(res);
  #		//console.log(data.toString());
  #        //var results = re.exec(data.toString());
  #        //console.log(results);
  #});
  options =
    url: url.url + "p" + page
    proxy: "http://" + proxy[proxy.length - 1]
    timeout: 20000
    headers: headers

  next = false
  request options, (error, response, body) ->
    if error
      logger.error error
      currentPage--
      next = true
      nextProxy()
      return
    unless 200 is response.statusCode
      currentPage--
      next = true
      nextProxy()
      return
    if not error and response.statusCode is 200
      re = /<a href="\/shop\/(.*)" class="BL"/g
      matches = undefined
      next = false
      while matches = re.exec(body)
        next = true
        logger.info "pushing todo item:" + matches[1]
        todoItems.push matches[1]
      unless body.indexOf("找到满足条件的商户") is -1
        next = true
        url = urls.pop()
        businessDao.updateUrl url
        currentPage = 0
        return
      re = /<span class="PageSel">(.*)<\/span>/g
      while matches = re.exec(body)
        unless matches[1] is page
          
          #if(!next && urls.length>0){
          next = true
          url = urls.pop()
          businessDao.updateUrl url
          currentPage = 0
          return
    return

  return
decode = (C) ->
  digi = 16
  add = 10
  plus = 7
  cha = 36
  I = -1
  H = 0
  B = ""
  J = C.length
  G = C.charCodeAt(J - 1)
  C = C.substring(0, J - 1)
  J--
  E = 0

  while E < J
    D = parseInt(C.charAt(E), cha) - add
    D = D - plus  if D >= add
    B += (D).toString(cha)
    if D > H
      I = E
      H = D
    E++
  A = parseInt(B.substring(0, I), digi)
  F = parseInt(B.substring(I + 1), digi)
  L = (A + F - parseInt(G)) / 2
  K = (F - L) / 100000
  L /= 100000
  lat: K
  lng: L
proxiedQueryItem = (item) ->
  logger.info "crawling " + item
  options =
    url: "http://www.dianping.com/shop/" + item
    proxy: "http://" + proxy[proxy.length - 1]
    timeout: 10000
    headers: headers

  blockingItems.push item
  request options, (error, response, body) ->
    blockingItems.pop()
    if error
      todoItems.push item
      logger.error error
      nextProxy()
      return
    unless 200 is response.statusCode
      todoItems.push item
      nextProxy()
      return
    if not error and response.statusCode is 200
      try
        re = /<h1 class="shop-title" itemprop="name itemreviewed">([^<]*)<\/h1>/
        results = re.exec(body)
        res =
          sourceId: item
          name: S(results[1]).trim().s
          source: "dianping"
          sourceId: item

        res.hasBranch = 1  unless body.indexOf("分店") is -1
        re = /<span itemprop="street-address">([^<]*)<\/span>/
        results = re.exec(body)
        res.address = S(results[1]).trim().s
        re = /<span class="region" itemprop="locality region">(.*)<\/span>/
        results = re.exec(body)
        res.region = S(results[1]).trim().s
        re = /<span class="bread-name" itemprop="title">([^<]*)<\/span>/g
        results = re.exec(body)
        results = re.exec(body)
        results = re.exec(body)
        res.region2 = S(results[1]).trim().s
        res.category1 = "美食"
        results = re.exec(body)
        res.category2 = S(results[1]).trim().s  if results
        results = re.exec(body)
        res.category3 = S(results[1]).trim().s  if results
        re = /poi: ["'](.*)["']/
        results = re.exec(body)
        unless results
          logger.error "parse poi error on item:" + item
          
          #todoItems.push(item);
          nextProxy()
          return
          
          #logger.info(body);
          next = false
          return
        poi = S(results[1]).trim().s
        poi = decode(poi)
        res.latitude = poi.lat
        res.longitude = poi.lng
        res.geohash = geohash.encode(res.latitude, res.longitude)  if res.latitude and res.longitude
        console.log res
        businessService.insert res
      catch e
        logger.error "parse rror on item:" + item + " error:" + e
        
        #todoItems.push(item);
        nextProxy()
        return
    return

  return

#console.log(body) // Print the google web page.
queryUrls = ->
  businessDao.queryUrls (results, error) ->
    if error
      logger.error error
    else urls = urls.concat(results)  if results
    return

  return

#proxiedQueryPage('http://www.dianping.com/search/category/5/10/g4581r65', 1);
#queryItem(5986025);
#proxiedQueryItem(5538379);
updateProxy = ->
  logger.info "start query new proxies"
  request
    url: "http://www.site-digger.com/html/articles/20110516/proxieslist.html"
    timeout: 10000
  , (error, response, body) ->
    logger.error error  if error
    logger.info "queried new proxies"
    re = /<td>([\d.:]*)<\/td>/g
    matches = undefined
    proxy = []
    while matches = re.exec(body)
      logger.info matches[1]
      proxy.push matches[1]
    return

  return
nextProxy = ->
  proxy.pop()
  updateProxy()  if proxy.length <= 3
  return
http = require("http")
request = require("request")
require "./config/config"
businessService = require(ROOT + "service/businessService")
businessDao = require(ROOT + "dao/businessDao")
S = require("string")
geohash = require("ngeohash")
logger = require("log4js").getLogger(__filename)
headers =
  Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  "Accept-Encoding": "deflate,sdch"
  "Accept-Language": "zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4"
  "Cache-Control": "no-cache"
  Connection: "keep-alive"
  Host: "www.dianping.com"
  Pragma: "no-cache"
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"
  Cookie: "_hc.v=\"\"3b801394-1439-48f9-bc20-57d1b5a84d66.1398687560\"\"; tc=5; abtest=\"47,122|44,107|45,116\"; is=334431760877; ano=50qPs41kzwEkAAAAZDZjNzQ2OGYtZWM4Ni00OTllLWI1Y2QtZTg3YTc4NzRmYmFkEMAwn-18UdrOhDUEMB239uccdts1; sid=d5lk3z2oichkou55pxchgn45; PHOENIX_ID=0a010406-145af3c4836-315aa; JSESSIONID=C83F1032948A6ECB0BBB3C37A2EBBBF1; aburl=1; cy=5; cye=nanjing; __utma=1.284892197.1398687561.1398779639.1398813793.5; __utmb=1.57.10.1398813793; __utmc=1; __utmz=1.1398687561.1.1.utmcsr=google.com.hk|utmccn=(referral)|utmcmd=referral|utmcct=/; s_ViewType=1; ab=; lb.dp=1141113098.20480.0000"

todoItems = []
blockingItems = []
setInterval (->
  return  if proxy.length is 0
  proxiedQueryItem todoItems.pop()  if todoItems.length > 0 and blockingItems.length < 3
  return
), 1000
currentPage = 0
next = true
urls = []
count = 0
setInterval (->
  return  if proxy.length is 0
  count++
  if urls.length > 0
    proxiedQueryPage urls[urls.length - 1], ++currentPage  if todoItems.length is 0 and next
  else
    if count >= 3
      count = 0
      queryUrls()
  return
), 10000
proxy = []
updateProxy()
queryUrls()
