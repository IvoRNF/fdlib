var ffi = require('ffi-napi')

 
var lib = ffi.Library('./FDLib.dll', {
  'query': [ 'string',['string','string'] ],
  'update' : [ 'string',['string','string'] ]  
})


exports.query = lib.query
exports.update = lib.update



 
