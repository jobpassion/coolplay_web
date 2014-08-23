local = require ROOT + 'config/local.en'
multiline = require 'multiline'
CronJob = require('cron').CronJob
request = require("request")
#request = request.defaults({jar: true})
tough = require('tough-cookie')
rl = require ROOT + 'service/stdInputService'
rl = rl.rl
answersCache = {}
users = [
  userName:'oak1987@163.com'
  loginToken:'__p__=48853b45ff9c83ff23f9a6c5e5d6a8e249ae1d398323bade6a94b26f83afed36'
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

refreshBySessionUser = (session, user)->
  request {url:'http://www.600280.com/member/index', headers:{Cookie:user.loginToken, jar:session.jar}}, (error, response, body)->
    try
      if response.headers['set-cookie']
        session.jar.setCookie(response.headers['set-cookie'][0], 'http://www.600280.com')
        session.lastUpdate = new Date().getTime()
        session.status = 1
        #console.log 'login ' + response.headers['set-cookie'][0]
    catch e 
      console.error e
cJob = new CronJob('*/1 * * * * *', ()->
  for user in users
    if user.status==1
      for session in user.sessions
        if !session.lastUpdate or new Date().getTime() - session.lastUpdate >=10*60*1000
          refreshBySessionUser session, user
          break
      while user.sessions.length < 3
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
      console.log 'query ' + session.lastUpdate
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
            cJob.start()
    catch e
      #submitJob = new CronJob('55 59 11 * * 5', ()->
submitJob = new CronJob('0 * * * * *', ()->
  inter = setInterval ()->
    b = false
    for user in users
      if user.status!=1 or user.sessions.length==0
        continue
      for session in user.sessions
        user.sessions.shift()
        if session.status!=2
          _j--
          continue
        submitBySessionUser session, user
        b = true
        break
    if !b
      clearInterval inter
  ,200
,null, true)
submitBySessionUser = (session, user)->
 request.post {url:'http://zf.600280.com//order/addSecKill', form:{
   verifyAns:session.answer
   addressIds:session.addressIds
   onlyFee:0
   remark:'如需发票请注明发票抬头(个人或单位)、发票类型(普通或增值税)及发票内容'
 }, jar:session.jar}, (error, response, body)->
   if error
     console.log error
   if body.indexOf('"result":"0"')!=-1
     console.log local.success + ':' + user.url
     user.status = 2
