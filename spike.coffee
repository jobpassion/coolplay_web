require "./config/config"
readline = require "readline"


rl = readline.createInterface({

  input: process.stdin

  output: process.stdout

})



rl.question("What do you think of node.js? ", (answer)-> 
  console.log("Thank you for your valuable feedback:", answer)
  rl.close()
)

