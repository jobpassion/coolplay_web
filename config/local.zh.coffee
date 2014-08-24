multiline = require 'multiline'
exports.command_query = multiline ()->
  ###
    请输入命令:
  ###
exports.list_users = '列出用户'
exports.add_job = '添加任务'
exports.help = '帮助'
exports.ok = 'ok'
exports.ask_url = '请复制链接进来'
exports.adding = multiline ()->
  ###
  正在为用户:%s添加任务
  ###

exports.welcome = multiline ()->
  ###
  #   欢迎回来
  #
  #     命令列表:
  #         %s
  #         %s
  #         %s
  ###
