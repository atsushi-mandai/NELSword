// SPDX-License-Identifier: MIT
// ATSUSHI MANDAI CRDIT Contracts
pragma solidity ^0.8.0;

import "./token/ERC4907/ERC4907.sol";
import "./interfaces/IERC20.sol";
import "./access/Ownable.sol";

/// @title NELSword
/// @author Atsushi Mandai
/// @notice generates Sword NFT.
contract NELSword is ERC4907, Ownable {

    constructor(string memory name, string memory symbol)
     ERC4907("NELSword", "NELSWORD")
     {         
     }

    uint256 public totalSupply = 0;
    uint256 public priceTITAN = 10000 * (10**18);
    uint256 public priceNEL = 5 * (10**17);
    address public addressTITAN = 0xaAa5B9e6c589642f98a1cDA99B9D024B8407285A;
    address public addressNEL;

    struct Metadata {
        uint8 increaseAttack;
        uint8 rarity;
    }
    mapping(uint => Metadata) public metadatas;

    /*
     * @dev public governance functions.
     */
    
    function changePriceTITAN(uint256 _newPrice) public onlyOwner {
        priceTITAN = _newPrice;
    }

    function changePriceNEL(uint256 _newPrice) public onlyOwner {
        priceNEL = _newPrice;
    }

    function changeAddressTITAN(address _address) public onlyOwner {
        addressTITAN = _address;
    }

    function changeAddressNEL(address _address) public onlyOwner {
        addressNEL = _address;
    }

    function withdraw() public onlyOwner {
        IERC20 titan = IERC20(addressTITAN);
        titan.transfer(_msgSender(), titan.balanceOf(address(this)));
        IERC20 nel = IERC20(addressNEL);
        nel.transfer(_msgSender(), nel.balanceOf(address(this)));
    }

    /*
     * @dev public general functions
     */
    
    function mintSword() public {
        IERC20 titan = IERC20(addressTITAN);
        titan.transferFrom(_msgSender(), address(this), priceTITAN);
        IERC20 nel = IERC20(addressNEL);
        nel.transferFrom(_msgSender(), address(this), priceNEL);
        _mint(_msgSender(), totalSupply);
        uint8 rarity;
        uint8 increaseAttack;
        (rarity, increaseAttack) = _generateMetadata();
        metadatas[totalSupply] = Metadata(rarity, increaseAttack);
        totalSupply = totalSupply + 1;
    }

    function _generateMetadata() private view returns(uint8, uint8) {
        uint256 value = uint256(keccak256(abi.encodePacked(_msgSender(), block.timestamp, totalSupply))) % 100;
        uint8 rarity;
        if(value == 0) {
            rarity = 3;
        } else if(value <= 5) {
            rarity = 2;
        } else if(value <= 20) {
            rarity = 1;     
        } else {
            rarity = 0;
        }
        uint8 base;
        uint8 rand = uint8(uint256(keccak256(abi.encodePacked(_msgSender(), block.timestamp, totalSupply))) % 21);
        if(rarity == 0) {
            base = 0;
        } else if(rarity == 1) {
            base = 20;
        } else if(rarity == 2) {
            base = 50;
        } else {
            base = 100;
        }
        return(rarity, base + rand);
    }

}