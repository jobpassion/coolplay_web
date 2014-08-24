require "./config/config"
local = require ROOT + 'config/local.en'
spikeService = require ROOT + 'service/spikeService'
rl = require ROOT + 'service/stdInputService'
rl = rl.rl



#rl.question("What do you think of node.js? ", (answer)-> 
#  console.log("Thank you for your valuable feedback:", answer)
#  rl.close()
#)
spikeService.welcome()
rl.on('line', (cmd)->
  #console.log('You just typed: '+cmd)
  spikeService.process cmd
)
###
readInput = ()->
  rl.question local.command_query + '\n', (answer)->
    console.log 'input:' + answer
    spikeService.process answer
    readInput()

readInput()
###
