local = require ROOT + 'config/local.en'
multiline = require 'multiline'
logger = require("log4js").getLogger(__filename)
CronJob = require('cron').CronJob
request = require("request")
#request = request.defaults({jar: true})
tough = require('tough-cookie')
properties = require('properties')
rl = require ROOT + 'service/stdInputService'
fs = require 'fs'
rl = rl.rl
answersCache = {}

properties.parse "spikeCache", { path: true }, (error, obj)->
  if error
    return console.error error
  answersCache = obj
users = [
  userName:'ridk2020@163.com'
  loginToken:'__p__=508669b24f189e6d2df2395b52cd99a0b9f9c8656cac1e051a80a096294f09d2'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'feng070900@163.com'
  loginToken:'__p__=fd548bbf72132ce8142f81f7e7366554cb123354e4dc1b863c07408d018cb2d1'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'sasa4428@163.com'
  loginToken:'__p__=f1ea01f660a7e23ed07ee92af8c79c5923fe01b6952bdc027c9864d8074f1cd2'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'dada3028@163.com'
  loginToken:'__p__=77c4b9865dfa1e1f2d8e496a56fee63d8dd9d0c0377c1ad8e6987cd2ec2b6b07'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'fsafsa1818@163.com'
  loginToken:'__p__=58b16b13fc3840ffa7a5950f0fa4ae82ee02850f62af7d2922aa34a016481444'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'jaja3028@163.com'
  loginToken:'__p__=3f7f8a0f20d4071a905e82550448160960a130521b33e51f6d6c4e0036f6362f'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'iiuyt12@163.com'
  loginToken:'__p__=28501cd91c903540f65a1b8afff0cb3148c9e63691fdff754dfe77eb42b9ac7a'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'nmbv1212@163.com'
  loginToken:'__p__=5a013bbeb826508892cd12782e0066a70fe11908a708f16d85bea1dcf915eb24'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'yrej1983@163.com'
  loginToken:'__p__=b014f37e16d4507873fb78089f78960e95328a8145f6188bd7e22a469c5b0dfa'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'vfrtgb1313@163.com'
  loginToken:'__p__=2617359d83ae6cc5a67f4bc5018dd8691f79196c252a1f9b0e89982f8f2fd753'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'agag2727@163.com'
  loginToken:'__p__=9f7e18df8a62f096e231ae28ee053a542f179162f330319a0413349069d2a9f6'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'wow123123wow@163.com'
  loginToken:'__p__=2d3493f7c8a6b8ba1a0a96e7ecbef3e527a603e4ef6afbbce7683687c77b0081'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'qwe456yy456@163.com'
  loginToken:'__p__=74bbc66bdaaa09a68d7db05d86f7216cdf07cfe541a279505ef45772e0d23e18'
  jar:request.jar()
  status:0
  sessions:[]
,
  userName:'yui789yuioo@163.com'
  loginToken:'__p__=1f17132b66c8f56fa772a0c5e4c724f235e8a0245171f33efe68b8e9ecec3011'
  jar:request.jar()
  status:0
  sessions:[]
]
listUsers = ()->
  console.log multiline ()->
      ###
      id  userName  status
      ###
  for user in users
    console.log (multiline ()->
      ###
      %s  %s  %s
      ###
      )
      , _i, user.userName, user.status
requestionRegex = /onclick="refreshQue\(\);">(.*)<\/span>/
addJob = (cmd)->
  for user in users
    if user.status==1
      continue
    console.log local.adding, user.userName
    rl.question local.ask_url + '\n', (res)->
      user.status = 1
      user.url = res
    break
_addJob = (url)->
  for user in users
    if user.status==1
      continue
    console.log local.adding, user.userName
    user.status = 1
    user.url = url
    break
        
exports.process = (cmd)->
  switch cmd
    when local.list_users then listUsers()
    when local.add_job then addJob(cmd)
    when local.help then console.log local.welcome
exports.welcome = ()->
  console.log local.welcome, local.list_users, local.add_job, local.help

refreshSessionCount = 0
querySessionCount = 0
refreshBySessionUser = (session, user)->
  session.refreshing = 1
  request {url:'http://www.600280.com/member/index', headers:{Cookie:user.loginToken, jar:session.jar}}, (error, response, body)->
    try
      if response.headers['set-cookie']
        #for i of session.jar
        #  console.log i + '===' + session.jar[i]
        #session.jar.setCookieSync(response.headers['set-cookie'][0], 'http://www.600280.com')
        session.jar.setCookie(response.headers['set-cookie'][0], 'http://www.600280.com')
        session.lastUpdate = new Date().getTime()
        session.refreshing = null
        session.status = 1
        logger.info 'login ' + session.lastUpdate
        refreshSessionCount++
        logger.info 'refreshSessionCount:' + refreshSessionCount
    catch e 
      console.error user.userName
      console.error e
intervalPer100ms = setInterval(()->
  for user in users
    if user.status==1
      for session in user.sessions
        if session.refreshing==1
          continue
        if !session.lastUpdate or new Date().getTime() - session.lastUpdate >=20*60*1000
          refreshBySessionUser session, user
          break
      #while user.sessions.length < 100
      #  a=1
      #  session = {jar:request.jar()}
      #  user.sessions.push session
      #for session in user.sessions
      #  if session.status==1
      #    cJob.stop()
      #    queryBySessionUser session, user
      #    break
, 100)
cJob = new CronJob('* * * * * *', ()->
  logger.info 'cron per second excute'
  for user in users
    if user.status==1
      #for session in user.sessions
      #  if !session.lastUpdate or new Date().getTime() - session.lastUpdate >=30*60*1000
      #    refreshBySessionUser session, user
      #    break
      while user.sessions.length < 50
        a=1
        session = {jar:request.jar()}
        user.sessions.push session
      for session in user.sessions
        if session.querying ==1
          continue
        if session.status==1
          cJob.stop()
          queryBySessionUser session, user
          break
,null, true)
addressReg = /userPostAddressList = .*"id":(.*),"userId/
queryBySessionUser = (session, user)->
  session.querying = 1
  request {url:user.url, jar:session.jar}, (error, response, body)->
    cJob.start()
    try
      logger.info 'query ' + session.lastUpdate
      querySessionCount++
      logger.info 'querySessionCount:' + querySessionCount
      session.querying = null
      results = addressReg.exec body
      if results
        session.addressIds = results[1]
      #console.log session.addressIds
      results = requestionRegex.exec body
      session.status=2
      if results
        answer = ''
        if answersCache[results[1]]
          answer = answersCache[results[1]]
          session.answer = answer
        else
          cJob.stop()
          rl.question results[1] + '\n', (res)->
            console.log local.ok
            answer = res
            session.answer = answer
            fs.appendFile('spikeCache', '\n' + results[1] + '=' + answer, (err)->
            )
            cJob.start()
    catch e

      #submitJob = new CronJob('0 30 22 * * *', ()->
submitJob = new CronJob('39 59 11 * * 5', ()->
  clearInterval intervalPer100ms
  cJob.stop()
  inter = setInterval ()->
    b = false
    for user in users
      if user.status!=1 or user.sessions.length==0
        continue
      while user.sessions.length >0
        #for session in user.sessions
        session = user.sessions.shift()
        if session.status!=2
          #_j--
          #user.sessions.shift()
          continue
        submitBySessionUser session, user
        #user.sessions.shift()
        b = true
        break
    if !b
      clearInterval inter
  ,200
,null, true)
submitBySessionUser = (session, user)->
 #console.log('answer:' + session.answer + '>>' + session.addressIds + '>>' + JSON.stringify(session.jar))
 logger.info 'submit :' + session.addressIds
 request.post {url:'http://zf.600280.com//order/addSecKill', form:{
   verifyAns:session.answer
   addressIds:session.addressIds
   onlyFee:0
   remark:''
 }, jar:session.jar}, (error, response, body)->
   if error
     logger.error error
   logger.info body
   if body.indexOf('"result":"0"')!=-1 or body.indexOf("-1")!= -1 or body.indexOf("-2")!= -1
     logger.info local.success + ':' + user.url
     user.status = 2



_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=184281'
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=320190'
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934'#zhi
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934'
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934'

#ma
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318332'#guo

#jie
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326873'#mianmo

_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326873'
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326873'#mianmo
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326873'
#jia
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=318934'#zhi

#hua
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326975'#pangxie

_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326975'
_addJob 'http://zf.600280.com/order/querySecKillInfo?promId=534&skuId=326975'
