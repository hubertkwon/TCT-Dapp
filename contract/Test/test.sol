pragma solidity ^0.4.18;

contract SampleOverflow {
  string public statictext = "HelloStackOverFlow";
  bytes32 public byteText = "HelloStackOverFlow";
  
  function set(string data) public{
    require(bytes(data).length <= 32);
    bytes32 _stringBytes;

    // simplest way to convert 32 character long string
    assembly {
      // load the memory pointer of string with an offset of 32
      // 32 passes over non-core data parts of string such as length of text
      _stringBytes := mload(add(data, 32))
    }
  }
}