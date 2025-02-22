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
        uint256 tokenId;
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
        
        _tokenIds++;

        uint256 newRecordId = _tokenIds;

        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

        records[name] = DomainRecord(
            newRecordId,
            "", // FirstName LastName
            _ens,
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
                    '"name": "', records[name].name, '", ',
                    '"ens": "', records[name].ens, '", ',
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


        console.log("Registering domain %s to address %s", name, msg.sender);
    }

    function getAddress(string calldata name) public view returns (address) {
        console.log("Getting address for domain %s: %s", name, records[name].wallet);  
        return records[name].wallet;
    }

    modifier onlyDomainOwner(string calldata domain) {
      require(domains[domain] == msg.sender, "Not domain owner");
      _;
    }

    function setName(string calldata domain, string calldata name) public onlyDomainOwner(domain) {
        records[domain].name= name;

        console.log("Record updated for domain: %s", domain);
    }

    function setEmail(string calldata domain, string calldata email) public onlyDomainOwner(domain) {
        records[domain].email= email;

        console.log("Record updated for domain: %s", domain);
    }

    function setTwitter(string calldata domain, string calldata twitter) public onlyDomainOwner(domain) {
        records[domain].twitter= twitter;

        console.log("Record updated for domain: %s", domain);
    }

    function setLinkedIn(string calldata domain, string calldata linkedin) public onlyDomainOwner(domain) {
        records[domain].linkedin= linkedin;

        console.log("Record updated for domain: %s", domain);
    }

    function setWebsite(string calldata domain, string calldata website) public onlyDomainOwner(domain) {
        records[domain].website= website;

        console.log("Record updated for domain: %s", domain);
    }

    function setAvatar(string calldata domain, string calldata avatar) public onlyDomainOwner(domain) {
        records[domain].avatar= avatar;

        console.log("Record updated for domain: %s", domain);
    }

    function setVariant(string calldata domain, string calldata variant) public onlyDomainOwner(domain) {
        require(domains[domain] == msg.sender, "Not domain owner");
        
        records[domain].variant= variant;

        console.log("Record updated for domain: %s", domain);
    }

    function getRecord(string calldata name) public view returns (DomainRecord memory) {
      if (domains[name] == address(0)) {
        // Return an empty record if no domain is found
        return DomainRecord(0, "", "", address(0), "", "", "", "", "", "");
      } else {
        return records[name];
      }
    }

    function updateMetadata(string calldata domain) public onlyDomainOwner(domain) {
      string memory imageURI = records[domain].avatar; // Example if you want to use avatar as the image.
   
      string memory json = Base64.encode(
          abi.encodePacked(
              '{',
                  '"name": "', records[domain].name, '", ',
                  '"ens": "', records[domain].ens, '", ',
                  '"image": "', imageURI, '", ',
                  '"length": "', Strings.toString(StringUtils.strlen(domain)), '", ',
                  '"owner": "', Strings.toHexString(uint256(uint160(msg.sender)), 20), '", ',
                  '"email": "', records[domain].email, '", ',
                  '"twitter": "', records[domain].twitter, '", ',
                  '"linkedin": "', records[domain].linkedin, '", ',
                  '"website": "', records[domain].website, '", ',
                  '"avatar": "', records[domain].avatar, '", ',
                  '"variant": "', records[domain].variant, '"',
              '}'
          )
      );
   
      string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));
   
      uint256 tokenId = records[domain].tokenId;
      _setTokenURI(tokenId, finalTokenUri);
   
      console.log("Metadata updated for domain: %s", domain);
    }

}
