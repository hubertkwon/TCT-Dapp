    function stringToBytes32(string memory source) pure internal returns(bytes32 result) {
        require(source.length <= 32);
        
        bytes memory tempEmptyStringTest = bytes(source);
        
        
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }