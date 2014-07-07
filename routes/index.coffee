express = require("express")
router = express.Router()
businessService = require(ROOT + "service/businessService")
logger = require("log4js").getLogger(__filename)
daoHelper = require(ROOT + "dao/daoHelper")
config = require(ROOT + "config/config")
util = require("util")
dateutil = require("dateutil")
geoService = require(ROOT + "service/geoService")

# GET home page. 
router.get "/", (req, res) ->
  res.render "index",
    title: "Express"

  return


#router.get('/queryNearby', function(req, res){
router.all "/queryNearby", (req, res) ->
  if config.local
    req.body.latitude = 32.06582
    req.body.longitude = 118.77852
  #businessService.queryNearby req.body, (err, results) ->
  businessService.queryNearby {latitude:32.06697, longitude:118.77793}, (err, results) ->
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
  geoService.queryNearby {},(err, data)->
    res.json data
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
