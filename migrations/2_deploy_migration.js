const shake = artifacts.require("shake");

module.exports = function(deployer) {
  deployer.deploy(shake,"tamato","tmt",'0xC5e5287D649818046CC4ccE277365c0AD0542B02');
};
