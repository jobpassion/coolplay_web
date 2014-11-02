classMap = {}
exports.queryByParam = (_class, param, callback) ->
  if classMap[_class]
    Class = classMap[_class]
  else
    Class = AV.Object.extend _class
    classMap[_class] = Class
  query = new AV.Query Class
  for key,value of param
    query.equalTo key, value
  query.find
    success:(results)->
      callback null,results
    error:(error)->
      callback error,null
exports.insert = (_class, param, callback)->
  classObject = AV.Object.new _class
  for key,value of param
    classObject.set key, value
  classObject.save null, 
    success:(classObject)->
      #console.log classObject
      callback null, classObject
    error:(classObject, error)->
      #console.log error
      callback error, classObject
