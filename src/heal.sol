/// heal.sol -- Dai settlement module

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.4.24;

contract Fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract DaiLike {
    function dai (bytes32) public view returns (int);
    function heal(bytes32,bytes32,int) public;
}

contract Vow {
    address vat;
    address cow;  // flapper
    address row;  // flopper

    function era() public view returns (uint48) { return uint48(now); }
    modifier auth { _; }  // todo

    mapping (uint48 => uint256) public sin; // debt queue
    uint256 public Sin;   // queued debt
    uint256 public Woe;   // pre-auction 'bad' debt
    uint256 public Ash;   // on-auction debt

    uint256 public wait;  // flop delay
    uint256 public lump;  // fixed lot size
    uint256 public pad;   // surplus buffer

    uint256 constant ONE = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y;
        require(z <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function Awe() public view returns (uint) { return add(add(Sin, Woe), Ash); }
    function Joy() public view returns (uint) { return uint(DaiLike(vat).dai(bytes32(address(this)))) / ONE; }

    function file(bytes32 what, uint risk) public auth {
        if (what == "wait") wait = risk;
        if (what == "lump") lump = risk;
        if (what == "pad")  pad  = risk;
    }
    function file(bytes32 what, address addr) public auth {
        if (what == "flap") cow = addr;
        if (what == "flop") row = addr;
        if (what == "vat")  vat = addr;
    }

    function heal(uint wad) public {
        require(wad <= Joy() && wad <= Woe);
        Woe = sub(Woe, wad);
        require(int(mul(wad, ONE)) >= 0);
        DaiLike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, ONE)));
    }
    function kiss(uint wad) public {
        require(wad <= Ash && wad <= Joy());
        Ash = sub(Ash, wad);
        require(int(mul(wad, ONE)) >= 0);
        DaiLike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, ONE)));
    }

    function fess(uint tab) public auth {
        sin[era()] = add(sin[era()], tab);
        Sin = add(Sin, tab);
    }
    function flog(uint48 era_) public {
        require(add(era_, wait) <= era());
        Sin = sub(Sin, sin[era_]);
        Woe = add(Woe, sin[era_]);
        sin[era_] = 0;
    }

    function flop() public returns (uint) {
        require(Woe >= lump);
        require(Joy() == 0);
        Woe = sub(Woe, lump);
        Ash = add(Ash, lump);
        return Fusspot(row).kick(this, uint(-1), lump);
    }
    function flap() public returns (uint) {
        require(Joy() >= add(add(Awe(), lump), pad));
        require(Woe == 0);
        return Fusspot(cow).kick(this, lump, 0);
    }
}
