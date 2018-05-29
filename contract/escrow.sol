pragma solidity ^0.4.16;

import "./owned.sol";

interface token {
    function transfer(address recevier, uint amount) public;
}

contract TokenEscrow is owned{

    function TokenEscrow() public{
        owner = msg.sender;
    }

    struct Escrow{
        address token;
        uint tokenAmount;
        bool tokenReceived;
        uint price;
        address seller;
        address recipient;
    }

    mapping(address => Escrow) public escrows;
    Escrow escrow;

    function create(address token,uint tokenAmount, uint price, address seller, address buyer, address recipient) public{
        escrows[buyer] = Escrow(token, tokenAmount, false, price, seller, recipient);
    }

    function create(address token, uint tokenAmount,uint price, address seller, address buyer) public{
        create(token, tokenAmount, price, seller, buyer, buyer);
    }
    
    function() internal{
        escrow = escrows[msg.sender];

        if(escrow.token == 0)
            revert("Something bad happened");

        ERC20 token = ERC20(escrow.token);

        if(!escrow.tokenReceived){
            uint balance = token.balanceOf(this);
            if(balance >= escrow.tokenAmount)
                escrow.tokenReceived = true;
        }

        if(msg.value < escrow.price){
            revert("price is below");
        }

        token.transfer(escrow.recipient, escrow.tokenAmount);

        escrow.seller.transfer(escrow.price);

        delete escrows[msg.sender];
    }

    function kill() public ownerOnly{
        selfdestruct(msg.sender);
    }
}


