// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract RandomIpfsNtf is ERC721URIStorage, VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface private immutable i_vrfCoo;
    uint64 private immutable i_subId;
    bytes32 private immutable i_gasline;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMs = 3;
    uint32 private constant NUM_WORD = 1;
    uint256 s_tokenCounter;
    uint256 public constant mintFee = 1000;
    string[3] s_dogsURI;
    mapping(uint256 => address) s_requestIdToSender;
    enum Breed {
        A,
        B,
        C
    }

    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed breed, address minter);

    constructor(
        address vrfCoo,
        uint64 subId,
        bytes32 gasLine,
        uint32 callbackGasLimit,
        string[3] memory dogsURI
    )
        VRFConsumerBaseV2(vrfCoo)
        ERC721("Random Ipfs Nft", "RNFT")
        Ownable(msg.sender)
    {
        i_vrfCoo = VRFCoordinatorV2Interface(vrfCoo);
        i_subId = subId;
        i_gasline = gasLine;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_dogsURI = dogsURI;
    }

    function requestNft() public payable returns (uint256 requestId) {
        require(msg.value > mintFee);
        requestId = i_vrfCoo.requestRandomWords(
            i_gasline,
            i_subId,
            REQUEST_CONFIRMs,
            i_callbackGasLimit,
            NUM_WORD
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter += 1;
        uint256 rand = randomWords[0] % 100;
        Breed breed = getBreedFromRand(rand);
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogsURI[uint256(breed)]);
        emit NftMinted(breed, dogOwner);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    function getBreedFromRand(uint256 rand) public view returns (Breed) {
        uint256 calSum;
        uint256[3] memory changeArray = getChanceArray();
        for (uint i = 0; i < changeArray.length; i++) {
            if (rand >= calSum && rand < changeArray[i] + calSum) {
                return Breed(i);
            }
            calSum += changeArray[i];
        }
    }

    function getChanceArray() internal view returns (uint256[3] memory) {
        return [uint256(10), 30, 100];
    }

    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {}
}
