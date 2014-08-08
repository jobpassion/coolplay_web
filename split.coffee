config = require "./config/config"
logger = require("log4js").getLogger(__filename)
daoHelper = require './dao/daoHelper'

daoHelper.sql 'select * from webapp.tmpUrls where tmpUrls.count>=750 order by tmpUrls.count desc', (err, result)->
  if err
    console.error err
  if result.length>0
    for res in result
      console.log res.url + 'r5'
      console.log res.url + 'r2'
      console.log res.url + 'r4'
      console.log res.url + 'r6'
      console.log res.url + 'r12'
      console.log res.url + 'r3'
      console.log res.url + 'r10'
      console.log res.url + 'r1'
      console.log res.url + 'r9'
      console.log res.url + 'r7'
      console.log res.url + 'r8'
      console.log res.url + 'r13'
      console.log res.url + 'r5937'
      console.log res.url + 'r5938'
      console.log res.url + 'r5939'
      console.log res.url + 'r8847'
      console.log res.url + 'r8846'
      console.log res.url + 'r8848'
