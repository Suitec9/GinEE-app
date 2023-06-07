// SPDX-License-Identifier: UNLICENSED LICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IConnectlist.sol";

 contract GNIE is  ERC721Enumerable , Ownable {
     /**
      * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
      * token will be the concatenation of the `baseURI` and the `tokenId`.
      */
    string _baseTokenURI;
    
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;
    
    /// @dev Set the purchase price for each Fake Token
    uint256 public _tokenPrice = 0.01 ether;

    // max number of GNIENFT's
    uint256 public _maxTokenIds = 5 ;

    // Whitelist contract instance
    IConnectlist whitelist;
     
    // total number of tokenIds minted
    uint256 public tokenIds;

    // boolean to keep track of whether presale started or not
    bool public presaleStarted;

    // timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

constructor (string memory baseURI , address connectlistContract) ERC721("GNIE", "GNIE") {
    _baseTokenURI = baseURI ;
    whitelist = IConnectlist(connectlistContract);
 
} 

   function startPresale() public onlyOwner {
        presaleStarted = true;
        // Set presaleEnded time as current timestamp + 3 minutes
        // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 3 minutes;
    }

        function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < _maxTokenIds, "Exceeded maximum GNIE token supply");
        require(msg.value >= _tokenPrice, "Ether sent is not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _mint(msg.sender, tokenIds);
    }

        function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < _maxTokenIds, "Exceed maximum GNIE token supply");
        require(msg.value >= _tokenPrice, "Ether sent is not correct");
        tokenIds += 1;
        _mint(msg.sender, tokenIds);
    }


        /**
    * @dev _baseURI overrides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

     /**
    * @dev setPaused makes the contract paused or unpaused
      */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }
  
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call {value: amount} ("");
        require(sent, "Failed to send Ether");
    }

    // Function to recieve Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable{}
   
    }
