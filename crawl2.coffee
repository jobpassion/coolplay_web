config = require "./config/config"
geohash = require("ngeohash")
logger = require("log4js").getLogger(__filename)
daoHelper = require './dao/daoHelper'
proxyQuery = require("./proxyQuery")
env = require("jsdom").env
jquery = require("jquery")
S = require("string")
async = require 'async'
businessService = require(ROOT + "service/businessService")
businessDao = require(ROOT + "dao/businessDao")

count1 = 0
count2 = 0
count3 = 0

urls = []
currentPage = 0
todoItems = []
queryUrls = ->
  businessDao.queryUrls (results, error) ->
    if error
      logger.error error
    else urls = urls.concat(results)  if results
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



queryUrls()
proxiedQueryPage = (url, page, callback) ->
  #return  unless url
  logger.info "crawling page " + url.url + " page index:" + page
  async.waterfall [
    (next)->
      proxyQuery.query url.url + "p" + page, (error, response, body) ->
        env body, (errors, window) ->
          if(errors)
            next errors
          try
            $ = jquery(window)
            re = /<a href="\/shop\/(.*)" class="BL"/g
            matches = undefined
            while matches = re.exec(body)
              logger.info "pushing todo item:" + matches[1]
              todoItems.push matches[1]
            if body.indexOf("PageSel") == -1
              url = urls.pop()
              businessDao.updateUrl url
              currentPage = 0
              next null
              return
            re = /<span class="PageSel">(.*)<\/span>/g
            while matches = re.exec(body)
              if `matches[1] != page`
                url = urls.pop()
                businessDao.updateUrl url
                currentPage = 0
                next null
                return
            next null
          catch e
            next e
            return
          #next(null)
  ], (err)->
    if err
      logger.error 'bbbbbbb' + err.stack
      err = 
        value: url.url
        type: 'page'
        erMsg: err
      daoHelper.sql 'insert into error set ?', err, null
    callback()

proxiedQueryItem = (item, callback) ->
  logger.info "crawling " + item
  async.waterfall [
    (next)->
      proxyQuery.query "http://www.dianping.com/shop/" + item, (error, response, body) ->
        next null, item, error, response, body
    (item, error, response, body, next) ->
      try
        re = /<h1 class="shop-title" itemprop="name itemreviewed">\r\n(.*)/
        results = re.exec(body)
        res =
          sourceId: item
          name: S(results[1]).trim().s
          source: "dianping"
          sourceId: item
  
        res.hasBranch = 1  unless body.indexOf("分店") == -1
        re = /<span itemprop="street-address">\r\n(.+)/
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
          next "parse poi error on item:" + item
          return
        poi = S(results[1]).trim().s
        poi = decode(poi)
        res.latitude = poi.lat
        res.longitude = poi.lng
        res.geohash = geohash.encode(res.latitude, res.longitude)  if res.latitude and res.longitude
        console.log res
        businessService.insert res
        next null
        count3++
      catch e
        next e
  ], (err)->
    if err
      logger.error 'aaaaa' + err.stack
      err = 
        value: "http://www.dianping.com/shop/" + item
        type: 'item'
        errMsg: err
      daoHelper.sql 'insert into error set ?', err, null
    callback()
    count2++

intervalQuery = (quali)->
  logger.info "[" + __function + ":" + __line + "] thread:" + quali
  if todoItems.length > 30
    setTimeout(()->
      intervalQuery quali
    , 1000)
    return
  if urls.length > 0
    proxiedQueryPage urls[urls.length - 1], ++currentPage, ()->
    #proxiedQueryPage {url:'http://www.dianping.com/search/category/1/10/x128y129'}, 100, ()->
      setTimeout(()->
        intervalQuery quali
      , 1000)
  else
    queryUrls()
    setTimeout(()->
      intervalQuery quali
    , 1000)

intervalQueryItem = (quali)->
  logger.info "[" + __function + ":" + __line + "] item thread:" + quali
  logger.info 'todoItems:' + todoItems.length
  if todoItems.length > 0
    count1++;
    proxiedQueryItem todoItems.pop(), ()->
      setTimeout(()->
        intervalQueryItem quali
      , 1000)
  else
    setTimeout(()->
      intervalQueryItem quali
    , 1000)

intervalQuery 1
intervalQuery 2
intervalQuery 3

intervalQueryItem 1
intervalQueryItem 2
intervalQueryItem 3


setInterval(()->
  logger.info 'count1: ' + count1 + ' count2: ' + count2 + ' count3: ' + count3
, 5000)
