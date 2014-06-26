#var agent = require('webkit-devtools-agent');
interval1 = ->
  logger.info "[" + __function + ":" + __line + "] todo size " + todo.length
  if todo.length > 10
    setTimeout (->
      interval1()
      return
    ), 10000
    return
  daoHelper.sql "select id, sourceId from business where fix is null limit 0, 100", null, (results) ->
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
  proxyQuery.query "http://www.dianping.com/shop/" + obj.sourceId, (error, response, body) ->
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
      img = $(".thumb-switch").find("img")
      if img.length > 0
        obj.img = img.attr("src")
      else
        img = $($(".thumb-wrapper")[0]).find("img")
        obj.img = img.attr("src")  if img.length > 0
      obj.fix = 1
      logger.info "[" + __function + ":" + __line + "] " + JSON.stringify(obj)
      businessDao.updateBusiness obj, (results, error) ->
        logger.error "[" + __function + ":" + __line + "] " + error  if error
        logger.info "[" + __function + ":" + __line + "] succed saved item:" + obj.sourceId
        return

      window.close()
      return

    setTimeout (->
      interval2 quali
      return
    ), 1000
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
