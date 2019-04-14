const Web3 = require('web3')
const rpcURL = "https://rinkeby.infura.io/v3/479f54915d594089a1243f67d15fbd09"
const web3 = new Web3(rpcURL)
const address = "0xD8dD29D7707f0E02e3047d72B5c8E28F5f1d107c"
const contractAddress = "0x83118ca190da02be9cc0c3599461eb67df85cfae"
const abi = require('./methods.json')

const myContract = new web3.eth.Contract(abi, contractAddress)

// var promise1 = new Promise(function(resolve, reject){
//   resolve(myContract.methods.getStudents().call().then(JSON.stringify)) 
// })
// promise1.then(
//   myContract.methods.getStudentDetails("0x0c5C69c82aa3060403b0f9cDFBD87Cb8c0D1A2D0").call().then(console.log)
// )
// promise1.then(
//   myContract.methods.getRecordDetails("0x38d2867e0b1905cf711d387692b32554db2b6f1ce26539909fea9cb7dc13ca96").call().then(console.log)
// )

var S;
var split = [];

var promise2 = new Promise(function(resolve, reject){
 resolve(myContract.methods.getStudents().call().then((result) => {
  S = JSON.parse(result);
  
  console.log(S)
 
  //  console.log(split[0]);
  //  console.log(split[3]);
  //  console.log(split);
  //  console.log(result)
 
 })) 
})
// promise2.then(
//   myContract.methods.getStudentDetails(split[0]).call().then(console.log)
// )



//  myContract.methods.getStudentDetails("0x0c5C69c82aa3060403b0f9cDFBD87Cb8c0D1A2D0").call().then(console.log);
// myContract.methods.getRecordDetails("0x38d2867e0b1905cf711d387692b32554db2b6f1ce26539909fea9cb7dc13ca96").call().then(console.log);


// web3.eth.getBalance(address, (err, wei) => {
//         console.log(balance = web3.utils.fromWei(wei, 'ether')) 
//       })


