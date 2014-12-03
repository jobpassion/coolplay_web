#config = require "cloud/config/config"
#userService = require 'cloud/service/userService'
#AV.Cloud.beforeSave 'FileUpload', (request)->
#  file = request.object
#  file = file.get 'data'
#  width = file.metaData().originWidth
#  height = file.metaData().originHeight
#  newSize = scale 
#    width:width
#    height:height, 150, 800
#  url = file.thumbnailURL newSize.width, newSize.height
#  console.log url
#  file.set 'thumbnail', url
#  
#scale = (size, width, height)->
#  oldWidth = size.width
#  oldHeight = size.height
#  scaleFactor = width / oldWidth
#  scaleFactor2 = height / oldHeight
#  if scaleFactor2 < scaleFactor
#    scaleFactor = scaleFactor2
#  width:Math.round oldWidth*scaleFactor
#  height:Math.round oldHeight*scaleFactor
#  
