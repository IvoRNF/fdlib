var ffi = require('ffi-napi');

 
var fdlib = ffi.Library('./fdlib/Win64/Debug/FDLib.dll', {
  'query': [ 'string',['string','string'] ],
  'update' : [ 'string',['string','string'] ]  
});

var sett = {
    database:"localhost/3050:/store/store_3.fdb",
    driverid : "FB",
    username : "sysdba",
    password : "masterkey"
}

console.log( fdlib.update(JSON.stringify(sett),"update filial set nome = 'IVO TESTE 2' where codigo = '1'")) // 2
 

console.log( fdlib.query(JSON.stringify(sett),"select codigo,nome from filial where codigo = '1'")) // 2
 
