// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import { StringUtils } from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    uint256 private _tokenIds;
    string public tld;

    enum Variant { NeoChrome, Obsidian, PlatinumPrism , CelestialVortex, MythicRelic }
    mapping(Variant => uint256) public upgradeCost;

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
        Variant variant;
        uint256 expirationTime;
    }

    mapping(string => address) public domains;
    mapping(string => DomainRecord) public records;
    string[] public registeredDomains; // Stores registered domain names

    constructor(string memory _tld) payable ERC721("Bizz Business Cards", "BIZ") {
        tld = _tld;
        upgradeCost[Variant.Obsidian] = 0.1 ether;
        upgradeCost[Variant.PlatinumPrism] = 0.2 ether;
        upgradeCost[Variant.CelestialVortex] = 0.5 ether;
        upgradeCost[Variant.MythicRelic] = 1.0 ether;
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

        uint256 oneYear = 365 days;

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
            Variant.NeoChrome,  // variant 
            block.timestamp + oneYear
        );

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, imageURI);
        
        domains[name] = msg.sender;
        registeredDomains.push(name);

        console.log("Registered domain %s to address %s", name, msg.sender);
    }

    function getAddress(string calldata name) public view returns (address) {
        console.log("Getting address for domain %s: %s", name, records[name].wallet);  
        return records[name].wallet;
    }

    modifier onlyDomainOwner(string calldata domain) {
      require(domains[domain] == msg.sender, "Not domain owner");
      _;
    }

    modifier checkExpired(string calldata domain) {
    require(records[domain].expirationTime > block.timestamp, "Domain expired");
      _;
    }

    function setName(string calldata domain, string calldata name) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].name= name;

        console.log("Record updated for domain: %s", domain);
    }

    function setEmail(string calldata domain, string calldata email) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].email= email;

        console.log("Avatar updated for domain: %s", domain);
    }

    function setTwitter(string calldata domain, string calldata twitter) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].twitter= twitter;

        console.log("Avatar updated for domain: %s", domain);
    }

    function setLinkedIn(string calldata domain, string calldata linkedin) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].linkedin= linkedin;

        console.log("Avatar updated for domain: %s", domain);
    }

    function setWebsite(string calldata domain, string calldata website) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].website= website;

        console.log("Avatar updated for domain: %s", domain);
    }

    function setAvatar(string calldata domain, string calldata avatar) public onlyDomainOwner(domain) checkExpired(domain) {
        records[domain].avatar= avatar;

        console.log("Avatar updated for domain: %s", domain);
    }

    function setVariant(string calldata domain, Variant newVariant) public onlyDomainOwner(domain) checkExpired(domain) payable {
        uint256 cost = upgradeCost[newVariant];
        require(msg.value >= cost, "Not enough Ether sent");
        records[domain].variant= newVariant;

        console.log("Variant updated for domain: %s", domain);
    }

    function getRecord(string calldata domain) public view returns (DomainRecord memory) {
      if (domains[domain] == address(0)) {
        return DomainRecord(0, "", "", address(0), "", "", "", "", "", Variant.NeoChrome, 0);
      } else {
        return records[domain];
      }
    }

    function getDomainsByOwner(address owner) public view returns (string[] memory) {
      uint256 count = 0;

    // Count how many domains are owned by `owner`
      for (uint256 i = 0; i < registeredDomains.length; i++) {
        string memory domain = registeredDomains[i];
        if (domains[domain] == owner) {
            count++;
        }
      }

    // Create an array of exact size
      string[] memory ownedDomains = new string[](count);
      uint256 index = 0;

    // Populate the array
      for (uint256 i = 0; i < registeredDomains.length; i++) {
        string memory domain = registeredDomains[i];
        if (domains[domain] == owner) {
            ownedDomains[index] = domain;
            index++;
        }
      }

      return ownedDomains;
    }

    function updateMetadata(string calldata domain) public onlyDomainOwner(domain) checkExpired(domain) {
      string memory imageURI = records[domain].avatar;
   
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

  function renew(string calldata domain) public payable onlyDomainOwner(domain) {
    require(records[domain].expirationTime <= block.timestamp, "Domain still valid");

    uint256 renewalFee = price(domain);
    require(msg.value >= renewalFee, "Insufficient payment");

    uint256 oneYear = 365 days;
    records[domain].expirationTime = block.timestamp + oneYear;

    console.log("Domain %s renewed for one more year", domain);
  }
}
