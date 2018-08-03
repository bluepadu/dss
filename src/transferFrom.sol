// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

contract VatLike {
    function dai(address) public view returns (int);
    function Tab() public view returns (uint);
    function move(address,address,uint) public;
}

contract Dai20 {
    VatLike public vat;
    constructor(address vat_) public  { vat = VatLike(vat_); }

    uint256 constant ONE = 10 ** 27;

    function balanceOf(address guy) public view returns (uint) {
        return uint(vat.dai(guy)) / ONE;
    }
    function totalSupply() public view returns (uint) {
        return vat.Tab() / ONE;
    }

    event Approval(address src, address dst, uint wad);
    event Transfer(address src, address dst, uint wad);

    mapping (address => mapping (address => uint)) public allowance;
    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] += wad;
        emit Approval(msg.sender, guy, wad * uint(-1));
        return true;
    }
    function approve(address guy) public {
        approve(guy, uint(-1));
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        vat.move(src, dst, wad);
        emit Transfer(src, dst, wad);
        return true;
    }
    function transfer(address guy, uint wad) public returns (bool) {
        transferFrom(msg.sender, guy, wad);
        return true;
    }

    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }
    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
}
