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

//console.log( fdlib.update(JSON.stringify(sett),"update filial set nome = 'IVO TESTE conceição' where codigo = '1'")) // 2
 
let ret = fdlib.query(JSON.stringify(sett),"select codigo,nome,precovenda,obs from ctprod order by codigo asc")
//ret = JSON.parse(ret)
console.log( ret ) // 2
 
