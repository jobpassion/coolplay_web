multiline = require 'multiline'
exports.command_query = multiline ()->
  ###
  what command ?
  ###
exports.list_users = 'list_users'
exports.add_job = 'add_job'
exports.ok = 'ok'
exports.ask_url = 'please enter the url of product'
exports.adding = multiline ()->
  ###
  adding job to user:%s
  ###

