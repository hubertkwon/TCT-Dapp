var express = require("express");
var app = express();
var server = require("http").createServer(app);
var io = require("socket.io")(server);

server.listen(8080);

app.use(express.static("public"));

app.get("/", function(req, res){
	res.sendFile(__dirname + "/public/html/index.html");
})



/*

var Web3 = require("web3");
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var tokenContract = web3.eth.contract([{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"count","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"getData","outputs":[{"name":"name","type":"string"},{"name":"data","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"uint256"}],"name":"dataBlock","outputs":[{"name":"name","type":"string"},{"name":"data","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_data","type":"uint256"}],"name":"insertData","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]);
var token = tokenContract.at("0xb10c532d14bf176ce9f95b7782b10c99f6355cb2");


console.log(parseInt(token.dataBlock("0xf1c6d931c76f2f8082ba6ba9bdd9a7566df7ff2e",3)[1]) + 5);



*/


/*

count값을 가져와서
for(int a = 0; i<count;i++){
console.log(token.dataBlock("0xf1c6d931c76f2f8082ba6ba9bdd9a7566df7ff2e",a));

}
usinged integer

voting 빼고

BlackList

arrest

crowdFunding

Astro

*/
