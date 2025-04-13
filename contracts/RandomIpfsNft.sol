// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

error Random_IPFS_OUT_OF_BOUND();
error IPFS_moreEthToBeSent();
error TransferFailed();

contract RandomNft is
    VRFV2WrapperConsumerBase,
    ERC721URIStorage,
    ConfirmedOwner
{
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );
    event nft_minted();

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests;

    uint8 private immutable i_MAX_CHANCE_VALUE;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256 public immutable i_mintFee;

    enum Dogbreed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;
    uint256 public s_TokenCounter;
    string[3] internal s_dogTokenUris;

    mapping(uint256 => address) public s_requestIdToSender;

    constructor(
        string[3] memory dogTokenUris,
        uint256 mintFee,
        address owner
    )
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
        ERC721("RandomNft", "RIN")
        ConfirmedOwner(owner)
    {
        s_dogTokenUris = dogTokenUris;
        i_mintFee = mintFee;
    }



    function requestNft() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert IPFS_moreEthToBeSent();
        }
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        s_requestIdToSender[requestId] = msg.sender;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        address dogOwner = s_requestIdToSender[_requestId];
        uint256 newTokenId = s_TokenCounter;
        uint8 moddedRng = uint8(_randomWords[0] % i_MAX_CHANCE_VALUE);
        Dogbreed breed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(breed)]);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(breed)]);
        s_TokenCounter++;
        emit nft_minted();
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getBreedFromModdedRng(
        uint8 moddedRng
    ) public view returns (Dogbreed) {
        uint256 cumulativeSum = 0;
        uint8[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArray[i]
            ) {
                return Dogbreed(i);
            }
            cumulativeSum += chanceArray[i];
        }
        revert Random_IPFS_OUT_OF_BOUND();
    }

    function getChanceArray() public view returns (uint8[3] memory) {
        return [10, 30, i_MAX_CHANCE_VALUE];
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(
        uint256 index
    ) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_TokenCounter;
    }
}
