// I hate JavaScript. I hate camelCase. >:(

var fs = require('fs');
var asmdb = require('./asmdb/index');
var x86db = new asmdb.x86util.X86DataBase().addDefault();

var instrs = x86db.getInstructionNames();
var res = ['{'];
for (var i=0; i<instrs.length; i++) res.push("  " + instrs[i] + ": true,");
res.push('}');

fs.writeFile('instructions.moon', res.join('\n'), function (err) {
    if (err) {
        console.log('YOU SUCK!!');
        console.log(err);
        return;
    }
});
