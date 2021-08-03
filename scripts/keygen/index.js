const keythereum = require("keythereum");
const fs = require('fs');

create()

function create() {
    if (process.argv.length === 2) {
        console.error('Please include password to launch the script');
        process.exit(1);
    }
    let password = process.argv[2]
    let dk = keythereum.create();

    let object = keythereum.dump(password, dk.privateKey, dk.salt, dk.iv);
    keythereum.exportToFile(object, "./keystore");
    console.log("Address:", "0x" + object.address)

    fs.writeFile('./passwords/' + "0x" + object.address, password, (err) => {
        if (err) throw err;
        console.log('Password file generated');
    })
}