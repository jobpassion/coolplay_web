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
        
exports.process = (cmd)->
  switch cmd
    when local.list_users then listUsers()
    when local.add_job then addJob(cmd)
    when local.help then console.log local.welcome
exports.welcome = ()->
  console.log local.welcome, local.list_users, local.add_job, local.help

refreshBySessionUser = (session, user)->
  request {url:'http://www.600280.com/member/index', headers:{Cookie:user.loginToken, jar:session.jar}}, (error, response, body)->
    try
      if response.headers['set-cookie']
        session.jar.setCookie(response.headers['set-cookie'][0], 'http://www.600280.com')
        session.lastUpdate = new Date().getTime()
        session.status = 1
        logger.info 'login ' + session.lastUpdate
    catch e 
      console.error e
cJob = new CronJob('* * * * * *', ()->
  logger.info 'cron per second excute'
  for user in users
    if user.status==1
      for session in user.sessions
        if !session.lastUpdate or new Date().getTime() - session.lastUpdate >=30*60*1000
          refreshBySessionUser session, user
          break
      while user.sessions.length < 100
        a=1
        session = {jar:request.jar()}
        user.sessions.push session
      for session in user.sessions
        if session.status==1
          cJob.stop()
          queryBySessionUser session, user
          break
,null, true)
addressReg = /userPostAddressList = .*"id":(.*),"userId/
queryBySessionUser = (session, user)->
  request {url:user.url, jar:session.jar}, (error, response, body)->
    cJob.start()
    try
      logger.info 'query ' + session.lastUpdate
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
submitJob = new CronJob('51 59 11 * * 5', ()->
#submitJob = new CronJob('0 53 * * * *', ()->
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
  ,100
,null, true)
submitBySessionUser = (session, user)->
 console.log('answer:' + session.answer + '>>' + session.addressIds + '>>' + JSON.stringify(session.jar))
 request.post {url:'http://zf.600280.com//order/addSecKill', form:{
   verifyAns:session.answer
   addressIds:session.addressIds
   onlyFee:0
   remark:''
 }, jar:session.jar}, (error, response, body)->
   if error
     console.log error
   console.log body
   if body.indexOf('"result":"0"')!=-1
     console.log local.success + ':' + user.url
     user.status = 2
