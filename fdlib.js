var ffi = require('ffi-napi')

 
var lib = ffi.Library('./node_modules/fdlib-win-x64/FDLib.dll', {
  'query': [ 'string',['string','string'] ],
  'update' : [ 'string',['string','string'] ] ,
  'release' : [ 'string',['string'] ]  
})


exports.query = lib.query
exports.update = lib.update
exports.release = lib.release



 
