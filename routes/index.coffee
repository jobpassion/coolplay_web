express = require("express")
router = express.Router()
businessService = require(ROOT + "service/businessService")
logger = require("log4js").getLogger(__filename)
daoHelper = require(ROOT + "dao/daoHelper")
util = require("util")
dateutil = require("dateutil")

# GET home page. 
router.get "/", (req, res) ->
  res.render "index",
    title: "Express"

  return


#router.get('/queryNearby', function(req, res){
router.all "/queryNearby", (req, res) ->
  businessService.queryNearby req.body, (results) ->
    
    #businessService.queryNearby({latitude:32.06697, longitude:118.77793}, function(results){
    res.json results
    return

  return

router.all "/queryComments", (req, res) ->
  logger.info "[" + __function + ":" + __line + "] " + JSON.stringify(req.body)
  req.body = businessId: 120  unless req.body.businessId
  businessService.queryComments req.body, (results) ->
    res.json results
    return

  return

router.all "/test", (req, res) ->
  daoHelper.sql "select * from businessReview where businessId=4439", [], (results) ->
    for obj of results
      obj = results[obj]
      if util.isDate(obj.createDate)
        obj.createDate.setHours obj.createDate.getHours() + 8
        obj.createDate = dateutil.format(obj.createDate, "y-m-d H:i")
      else
        obj.createDate = ""
    res.json results
    return

  return

router.all "/addReview", (req, res) ->
  unless req.body.businessId
    req.body =
      businessId: 120
      userName: "redrum"
      content: "testContent"
  req.body.createDate = new Date()
  businessService.addReview req.body, (results, error) ->
    unless error
      res.json success: 1
    else
      res.json success: 0
    return

  return

module.exports = router
