
var TCTDapp = artifacts.require("./TCTDapp.sol");






module.exports = function(deployer) {
  deployer.deploy(TCTDapp);
};

