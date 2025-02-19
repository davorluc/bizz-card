// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import { StringUtils } from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    uint256 private _tokenIds;
    string public tld;

    struct DomainRecord {
        string name;
        string ens;
        address wallet;
        string email;
        string twitter;
        string linkedin;
        string website;
        string avatar;
        string variant;
    }

    mapping(string => address) public domains;
    mapping(string => DomainRecord) public records;

    constructor(string memory _tld) payable ERC721("Bizz Business Cards", "BIZ") {
        tld = _tld;
        console.log("%s name service deployed", _tld);
    }

    function price(string calldata name) public pure returns (uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0, "Domain name cannot be empty");

        if (len == 3) {
            return 0.05 ether;
        } else if (len == 4) {
            return 0.03 ether;
        } else {
            return 0.01 ether;
        }
    }

    function register(string calldata name, string memory imageURI) public payable {
        require(domains[name] == address(0), "Domain already registered");

        uint _price = price(name);
        require(msg.value >= _price, "Not enough Ether paid");

        string memory _ens = string(abi.encodePacked(name, ".", tld));
        uint256 newRecordId = _tokenIds;

        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

        records[name] = DomainRecord(
            "", // FirstName LastName
            _ens, // ENS
            msg.sender, 
            "", // email
            "", // twitter
            "", // linkedin
            "", // website
            "", // avatar
            ""  // variant 
        );

        string memory json = Base64.encode(
            abi.encodePacked(
                '{',
                    '"name": "', _ens, '", ',
                    '"description": "A domain on the Bizz Name Service", ',
                    '"image": "', imageURI, '", ',
                    '"length": "', Strings.toString(StringUtils.strlen(name)), '", ',
                    '"owner": "', Strings.toHexString(uint256(uint160(msg.sender)), 20), '", ',
                    '"email": "', records[name].email, '", ',
                    '"twitter": "', records[name].twitter, '", ',
                    '"linkedin": "', records[name].linkedin, '", ',
                    '"website": "', records[name].website, '", ',
                    '"avatar": "', records[name].avatar, '", ',
                    '"variant": "', records[name].variant, '"',
                '}'
            )
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        
        domains[name] = msg.sender;

        _tokenIds++;

        console.log("Registering domain %s to address %s", name, msg.sender);
    }

    function getAddress(string calldata name) public view returns (address) {
        console.log("Getting address for domain %s: %s", name, records[name].wallet);  
        return records[name].wallet;
    }

    function setRecord(string calldata name, DomainRecord calldata record) public {
        require(domains[name] == msg.sender, "Not domain owner");
        
        records[name] = record;

        console.log("Record updated for domain: %s", name);
    }

    function getRecord(string calldata name) public view returns (DomainRecord memory) {
        return records[name];
    }

}
