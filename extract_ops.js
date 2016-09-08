// I hate JavaScript. I hate camelCase. >:(

var fs = require('fs');
var asmdb = require('./asmdb/index');
var x86db = new asmdb.x86util.X86DataBase().addDefault();

var instructions = {};

x86db.forEach(function (name, instr) {
    var sigs = [];
    for (var i=0; i<instr.operands.length; i++)
        sigs.push(instr.operands[i].data);
    instructions[name] = (instructions[name] || []).concat(sigs);

});

var tab = ['{'];
var api = ['{'];

for (var name in instructions) {
    tab.push("  " + name + ": true,");

    var orig_sigs = instructions[name];
    var sigs = [];
    var sig_obj = {};

    for (var i=0; i<orig_sigs.length; i++) sig_obj[orig_sigs[i]] = 0;
    orig_sigs = Object.keys(sig_obj);
    orig_sigs.sort();

    for (var i=0; i<orig_sigs.length; i++)
        sigs.push('# ' + name + ' ' + orig_sigs[i]);

    doc = '{description:"' + sigs.join('\\n') + '",signature:"' + name + '"}';
    api.push('  ' + name + ':' + doc);
}

tab.push('}');
api.push('}');

fs.writeFile('instructions.moon', tab.join('\n'), function (err) {
    if (err) {
        console.log('YOU SUCK!!');
        console.log(err);
        return;
    }
});

fs.writeFile('api.moon', api.join('\n'), function (err) {
    if (err) {
        console.log('YOU SUCK even MORE!!');
        console.log(err);
        return;
    }
});
