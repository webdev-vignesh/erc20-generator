// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LookUpContract {

    struct ERC20Token {
        uint256 tokenID;
        address owner;
        string tokenSupply;
        string tokenName;
        string tokenSymbol;
        string tokenAddress;
        string tokenTransactionHash;
        string tokenCreatedDate;
    }

    struct Donation {
        uint256 donationID;
        address donor;
        uint256 fund;
    }

    address payable constant CONTRACT_OWNER = payable(address(0xf30403D6b4286C56cc930E1962F7384eab50b76a));
    
    mapping(uint256 => ERC20Token) private s_erc20Tokens;
    mapping(uint256 => Donation) private s_donations;

    uint256 public s_tokenIndex;
    uint256 public s_donationIndex;
    uint256 public s_listingPrice = 0.0025 ether;

    event DonationReceived(address indexed donor, uint256 amount);
    event ERC20TokenListed(uint256 indexed id, address indexed owner, string indexed token);

    modifier onlyOwner() {
        require(msg.sender == CONTRACT_OWNER, "only owner of the contract can change the listing price");
        _;
    }

    function createERC20Token(
        address _owner, 
        string memory _tokenSupply, 
        string memory _tokenName, 
        string memory _tokenSymbol, 
        string memory _tokenAddress, 
        string memory _tokenTransactionHash, 
        string memory _tokenCreatedDate
    ) payable external returns (
        uint256, 
        address, 
        string memory, 
        string memory, 
        string memory, 
        string memory
    ) {
        s_tokenIndex++;
        uint256 _tokenId = s_tokenIndex;
        ERC20Token storage erc20Token = s_erc20Tokens[_tokenId];

        erc20Token.tokenID = _tokenId;
        erc20Token.owner = _owner;
        erc20Token.tokenSupply = _tokenSupply;
        erc20Token.tokenName = _tokenName;
        erc20Token.tokenSymbol = _tokenSymbol;
        erc20Token.tokenAddress = _tokenAddress;
        erc20Token.tokenTransactionHash = _tokenTransactionHash;
        erc20Token.tokenCreatedDate = _tokenCreatedDate;

        emit ERC20TokenListed(_tokenId, _owner, _tokenAddress);

        return (_tokenId, _owner, _tokenAddress, _tokenName, _tokenSymbol, _tokenAddress);
    }

    function getAllERC20TokenListed() public view returns (ERC20Token[] memory) {
        uint256 itemCount = s_tokenIndex;
        uint256 currentIndex = 0;

        ERC20Token[] memory items = new ERC20Token[](itemCount);
        for (uint256 i=0; i<itemCount; i++) {
            uint256 currentId = i + 1;
            ERC20Token storage currentItem = s_erc20Tokens[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }

        return items;
    }

    function getERC20Token(uint256 _tokenID) external view returns(
        uint256,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory
    ) {
        ERC20Token memory erc20Token = s_erc20Tokens[_tokenID];
        return (
            erc20Token.tokenID,
            erc20Token.owner,
            erc20Token.tokenSupply,
            erc20Token.tokenName,
            erc20Token.tokenSymbol,
            erc20Token.tokenAddress,
            erc20Token.tokenTransactionHash,
            erc20Token.tokenCreatedDate
        );
    }

    function getUserERC20Tokens(address _user) external view returns(ERC20Token[] memory) {
        uint256 totalItemCount = s_tokenIndex;
        uint256 userItemCount = 0;
        uint256 currentIndex = 0;
        // loop to find the count of user-generated ERC20 tokens from total count
        // so that we can make the return array static to save some gas
        for(uint256 i=0; i<totalItemCount; i++) {
            if (s_erc20Tokens[i+1].owner == _user) {
                userItemCount += 1;
            }
        }

        ERC20Token[] memory items = new ERC20Token[](userItemCount);
        // loop to push the datas of user-generated ERC20 tokens to the items list
        for (uint256 i=0; i<totalItemCount; i++) {
            if (s_erc20Tokens[i+1].owner == _user) {
                uint256 currentId = i+1;
                ERC20Token storage currentItem = s_erc20Tokens[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function getERC20TokenListingPrice() public view returns (uint256) {
        return s_listingPrice;
    }

    function updateListingPrice(
        uint256 _listingPrice, 
        address _owner
    ) public payable onlyOwner {
        require(_owner == CONTRACT_OWNER, "Only contract owner can update listing price");
        s_listingPrice = _listingPrice;
    } 

    function withdrwa() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No donations available for withdrawal");
        payable(CONTRACT_OWNER).transfer(balance);
    }

    function getContractBalance() external view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");

        s_donationIndex++;
        uint256 _donationId = s_donationIndex;
        Donation storage donation = s_donations[_donationId];

        donation.donationID = _donationId;
        donation.donor = msg.sender;
        donation.fund = msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    function getAllDonation() public view returns(Donation[] memory) {
        uint256 itemCount = s_donationIndex;
        uint256 currentIndex = 0;

        Donation[] memory items = new Donation[](itemCount);
        for (uint256 i=0; i<itemCount; i++) {
            uint256 currentId = i+1;
            Donation storage currentItem = s_donations[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return items;
    }

}