express = require("express")
router = express.Router()
userService = require(ROOT + "service/userService")
authInterceptor = require(ROOT + "auth/authInterceptor")

# GET users listing. 
router.get "/", (req, res) ->
  res.send "respond with a resource5"
  return

router.all "/register", (req, res) ->
  user = req.query
  userService.register user, (result, succ) ->
    res.json result
    return

  return

router.all "/thirdLogin", (req, res) ->
  user = req.body
  userService.thirdLogin user, (result, succ) ->
	  if(succ)
		  req.session.authorized = true
	  res.json result

router.all "/queryUserFavorite",authInterceptor.auth, (req, res) ->
  console.log 123
  params = req.body
  userService.queryUserFavorite params, (result) ->
    res.json result
    return

  return

router.all "/queryUserLike", authInterceptor.auth,(req, res) ->
  params = req.body
  userService.queryUserLike params, (result) ->
    res.json result
    return

  return

module.exports = router