const { expectThrow } = require("../helpers/expectThrow");
const { EVMRevert } = require("../helpers/EVMRevert");
const BigNumber = web3.BigNumber;
require("chai")
  .use(require("chai-as-promised")).use(require("chai-arrays"))
  .should();
const shake = artifacts.require("contracts/shake");
contract("shake", function(accounts){
    let shakes;
    const _nam = "food";
    const _sym = "fd";
    const totalsupply= "0";
    const nexttokenId = "0";
    
    const deployer=accounts[0];
    const user1=accounts[1];
    const user2=accounts[2];
    const role1=accounts[2];
    const role2=accounts[4];


    beforeEach(async function() {
        shakes = await shake.new(_nam,_sym, accounts[0],{
                from: accounts[0]
        });
    });
    describe(" after deployment",() => {
        it("name of the template", async function(){
            (await shakes.name()).should.eq(_nam);
            console.log("sucess")
        });

        it("symbol of template", async function (){
            (await shakes.symbol()).should.eq(_sym);
        });
        it("address of owner", async function () {
            (await shakes.owner()).should.eq(deployer);
        }); 
        
        
    });
    describe("total supply or next token id", ()=> {
        it(" total supply ", async function () {
            (await shakes.totalSupply()).toString().should.equal(totalsupply);
            
        });
        it(" next TokenId ", async  function() {
            (await shakes.nextTokenId()).toString().should.equal(nexttokenId);
        });

    });
    
    describe(" create  products for next TokenID with details", ()=>{
        const datalist1= ["one","two","three"];
        const datalist2 = ["four","five","six"];
        const url1 = "mg.url";
        const url2 = "or.url";
        const nexttotalsupply ="2";
        const isCounterfiet = false;
        const datarole = [1];
        beforeEach("sucessful minting token", async function() {
            const { logs } = await shakes.batchMint([user1,user2],[url1,url2],[datalist1,datalist2],{
                    from: deployer
            });
            this.logs=logs;
        });
        it("total supply after mint token",async function (){
            (await shakes.totalSupply()).toString().should.equal(nexttotalsupply);
        });
        it("next token id after creating one token", async function () {
            (await shakes.nextTokenId()).toString().should.equal("2");
        });
        it("owner of token id = 0", async function (){
            (await shakes.ownerOf(0)).toString().should.equal(user1);
        });
        it("owner of token id = 1", async function (){
            (await shakes.ownerOf(1)).toString().should.equal(user2);
        });
        it("get datalist after creating one product", async function(){
           (await shakes.getdatalist(0)).toString().should.equal(datalist1.toString());
        });
        it("get datalist after creating second product", async function(){
            (await shakes.getdatalist(1)).toString().should.equal(datalist2.toString());
         });
         
    });
    describe("failure of mint token for address", ()=>{
        const datalist1= ["one","two","three"];
        const url1 = "mg.url";
        it("reject invalid recipients", async () => {
            await shakes.mint(0x0,url1,datalist1, {from: deployer}).should.be
                    .rejected;
        });
    });
    describe("assigning the roles using stage", async ()=> {
        const datarole= [1];
        let result;
        
        beforeEach("sucessful assigning roles", async function(){
            result = await shakes.assignMultiple([role1],[user2],{
                from: user2
            });
        });
        
        it("gettings attributes that is assigned to role", async function(){
           result= (await shakes.stageattributes(user2, {from : user2}));
           result.should.eq(datarole.toString());
        }); 
       
    });
    describe(" update multiple attributes ", ()=>{
        const datalist3 = ["seven","eight","nine"];
        beforeEach("updating attributes", async function(){
            const result =  await shakes.updateMultipleattribute([1],[datalist3],{from : role1});
        });
        
        it("after updating the attributes datalist ", async function(){
            (await shakes.getdatalist(1)).toString().should.equal(datalist3.toString());
        });
    });


});
