var Oracle = artifacts.require("./Oracle.sol");
var Example = artifacts.require("./Example.sol");
const ZapCoordinator = artifacts.require('./ZapCoordinator.sol');
var OracleAddress;
const OracleEndpoint = "0x4f6e436861696e456e64706f696e744d6f696e00000000000000000000000000";

module.exports = function(deployer) {
    deployer.deploy(Oracle, ZapCoordinator.address)
        .then(() => Oracle.deployed())
        .then((_instance) => {
            console.log("Oracle Contract Address: ", _instance.address)
            OracleAddress = _instance.address;
        })
        .then( ()=> deployer.deploy(Example, ZapCoordinator.address, OracleAddress, OracleEndpoint) )
        .then(() => Example.deployed())
        .then((_instance) => console.log("Example Contract Address: ", _instance.address));
};


