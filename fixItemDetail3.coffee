#var agent = require('webkit-devtools-agent');
interval1 = ->
  logger.info "[" + __function + ":" + __line + "] todo size " + todo.length
  if todo.length > 10
    setTimeout (->
      interval1()
      return
    ), 10000
    return
  daoHelper.sql "select id, sourceId from business where fix2 is null limit 0, 100", null, (results) ->
    todo = todo.concat(results)
    setTimeout (->
      interval1()
      return
    ), 10000
    return

  return
interval2 = (quali) ->
  logger.info "[" + __function + ":" + __line + "] thread:" + quali
  if todo.length is 0
    setTimeout (->
      interval2 quali
      return
    ), 1000
    return
  obj = todo.pop()
  proxyQuery.query "http://www.dianping.com/shop/" + obj.sourceId + "/review_more", (error, response, body) ->
    logger.info "[" + __function + ":" + __line + "] queried item:" + obj.sourceId + "  with statusCode " + response.statusCode
    env body, (errors, window) ->
      
      #
      #			var $ = jquery(window)
      #			  ;
      #			var re = /   ¥([\d]+)/g;
      #			var matches;
      #			while (matches = re.exec(body)) {
      #				obj.price = matches[1];
      #			}
      #            re = /\d+/g;
      #			var tel = $('.call');
      #			tel = tel.text();
      #			tel = S(tel).trim().s;
      #			obj.tel = tel;
      #            obj.rating = $('meta[itemprop="rating"]').attr('content');
      #            if(!re.test(obj.rating)){
      #                obj.rating = null;
      #            }
      #            var t = $('.rst-taste').find('strong');
      #            obj.taste = $(t[1]).text();
      #            re = /\d+/g;
      #            if(!re.test(obj.taste)){
      #                obj.taste = null;
      #            }
      #            obj.ambience = $(t[2]).text();
      #            re = /\d+/g;
      #            if(!re.test(obj.ambience)){
      #                obj.ambience= null;
      #            }
      #            obj.serving = $(t[3]).text();
      #            re = /\d+/g;
      #            if(!re.test(obj.serving)){
      #                obj.serving= null;
      #            }
      #			
      $ = jquery(window)
      list = $(".comment-list>ul>li")
      objList = []
      i = 0

      while i < list.length
        o = $(list[i])
        o2 = {}
        o2.sourceId = o.attr("id").substr(4)
        o2.businessId = obj.id
        o3 = o.find(".name>a")
        o2.userName = o3.text()
        o2.userSourceId = o3.attr("href")
        o2.userSourceId = o2.userSourceId.substr(8)
        o2.createDate = o.find(".time").text()
        o2.content = S(o.find(".comment-txt").children().text()).trim().s
        o2.rateStatus = o.find(".item-rank-rst").attr("class").substr(22)  if o.find(".item-rank-rst").attr("class") and o.find(".item-rank-rst").attr("class").length > 22
        o2.rateStatus = o2.rateStatus.substring(0, 1)  if o2.rateStatus and o2.rateStatus.length > 0
        
        #if(o.find('.comm-per').text().length>5)
        #o2.price = o.find('.comm-per').text().substr(5);
        commentrst = o.find(".comment-rst").text()
        if commentrst.length > 0
          re = /口味(\d+)/g
          matches = undefined
          o2.taste = matches[1]  while matches = re.exec(commentrst)
          re = /环境(\d+)/g
          o2.ambience = matches[1]  while matches = re.exec(commentrst)
          re = /服务(\d+)/g
          o2.serving = matches[1]  while matches = re.exec(commentrst)
          re = /人均  ￥(\d+)/g
          commentrst = o.find(".comm-per").text()
          o2.price = matches[1]  while matches = re.exec(commentrst)
        o4 = o.find(".comment-recommend")
        o2.recommand = ""
        o2.park = ""
        o2.recommandAmbience = ""
        o2.recommandFeature = ""
        j = 0

        while o4.length > 0 and j < o4.length
          if $(o4[j]).text().indexOf("推荐菜") >= 0
            k = 0

            while k < $(o4[j]).find("a").length
              o2.recommand += " " + $($(o4[j]).find("a")[k]).text()
              k++
          else if $(o4[j]).text().indexOf("停车信息") >= 0
            k = 0

            while k < $(o4[j]).find("a").length
              o2.park += " " + $($(o4[j]).find("a")[k]).text()
              k++
          else if $(o4[j]).text().indexOf("餐厅氛围") >= 0
            k = 0

            while k < $(o4[j]).find("a").length
              o2.recommandAmbience += " " + $($(o4[j]).find("a")[k]).text()
              k++
          else if $(o4[j]).text().indexOf("餐厅特色") >= 0
            k = 0

            while k < $(o4[j]).find("a").length
              o2.recommandFeature += " " + $($(o4[j]).find("a")[k]).text()
              k++
          j++
        o5 = o.find(".thumb").find("img")
        o2.shopPhoto = ""
        if o5.length > 0
          j = 0

          while j < o5.length
            o2.shopPhoto += " " + $(o5[j]).attr("src")
            j++
        objList.push o2
        i++
      obj.fix2 = 1
      logger.info "[" + __function + ":" + __line + "] " + JSON.stringify(obj)
      daoHelper.sql "update business set fix2=? where id=?", [
        obj.fix2
        obj.id
      ], (results, error) ->
        logger.error "[" + __function + ":" + __line + "] " + error  if error
        logger.info "[" + __function + ":" + __line + "] succed saved item:" + obj.sourceId
        return

      i = 0

      while i < objList.length
        save objList[i]
        i++
      window.close()
      return

    setTimeout (->
      interval2 quali
      return
    ), 1000
    return

  return
save = (obj) ->
  daoHelper.sql "select * from businessReview where sourceId = ?", [obj.sourceId], (results, error) ->
    if results.length is 0
      daoHelper.sql "insert into businessReview set ?", obj, (results, error) ->
        logger.error "[" + __function + ":" + __line + "] " + error  if error
        logger.info "[" + __function + ":" + __line + "] succed saved item:" + obj.sourceId
        return

    return

  return
proxyQuery = require("./proxyQuery")
daoHelper = require(ROOT + "dao/daoHelper")
businessDao = require(ROOT + "dao/businessDao")
logger = require("log4js").getLogger(__filename)
env = require("jsdom").env
jquery = require("jquery")
S = require("string")
todo = []
interval1()
interval2 1
interval2 2
interval2 3
