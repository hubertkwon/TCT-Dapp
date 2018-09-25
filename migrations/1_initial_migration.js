var Migrations = artifacts.require("./CarData.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
