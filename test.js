var fdlib = require('./fdlib');


var sett = {
    database:"localhost/3050:/store/store_3.fdb",
    driverid : "FB",
    username : "sysdba",
    password : "masterkey"
}

let ret = fdlib.query(JSON.stringify(sett),"select * from sigcaut1")
console.log( ret ) // 2
 
