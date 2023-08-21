// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {StringToAddress, AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol";
import "./interface/IHotpot.sol";
import "./interface/IWrappedToken.sol";

contract CrosschainMarketplace is AxelarExecutable, ReentrancyGuard, Ownable {
    using StringToAddress for string;
    using AddressToString for address;

    error AlreadyInitialized();

    event FalseSender(string sourceChain, string sourceAddress);
    // Variables
    uint128 public itemCount;
    uint128 public activeItemCount;
    string public constant destinationChain = "base";
    string public symbol;
    IWrappedToken public immutable i_wrappedNativeToken;

    /* 
    Hotpot variables
     */
    uint256 public raffleTradeFee = 1000;
    uint256 constant HUNDRED_PERCENT = 10000;
    address public immutable i_hotpot;

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }
    IAxelarGasService public immutable gasService;

    constructor(
        IAxelarGasService _gasService,
        address gateway_,
        address _hotpot,
        string memory _symbol,
        IWrappedToken _wrappedNativeToken
    ) AxelarExecutable(gateway_) {
        gasService = _gasService;
        i_hotpot = _hotpot;
        symbol = _symbol;
        i_wrappedNativeToken = _wrappedNativeToken;
    }

    // itemId -> Item
    mapping(uint => Item) public items;

    event Offered(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );
    event Bought(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    // Make item to offer on the marketplace
    function makeItem(
        IERC721 _nft,
        uint _tokenId,
        uint _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        // increment itemCount
        itemCount++;
        activeItemCount++;
        // transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        // emit Offered event
        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price, market fee and cross-chain fee"
        );
        require(!item.sold, "item already sold");
        // pay seller and feeAccount
        item.seller.transfer(item.price);
        // update item to sold
        item.sold = true;
        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        activeItemCount--;

        /* 
            Hotpot Execute Cross-chain Trade
        */
        uint256 crossChainFee = msg.value - _totalPrice;
        uint256 _raffleFee = _totalPrice - item.price;
        i_wrappedNativeToken.deposit{value: _raffleFee}();
        require(
            i_wrappedNativeToken.approve(address(gateway), _raffleFee),
            "failed to approve wrapped native token"
        );
        bytes memory payload = abi.encode(_totalPrice, msg.sender, item.seller);
        gasService.payNativeGasForContractCallWithToken{value: crossChainFee}(
            address(this),
            destinationChain,
            i_hotpot.toString(),
            payload,
            symbol,
            _raffleFee,
            msg.sender
        );
        gateway.callContractWithToken(
            destinationChain,
            i_hotpot.toString(),
            payload,
            symbol,
            _raffleFee
        );

        // emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function _execute(
        string calldata, /*sourceChain*/
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        // if (sourceAddress.toAddress() != address(this)) {
        //     emit FalseSender(sourceAddress, sourceAddress);
        //     return;
        // }
        // (address to, uint256 amount) = abi.decode(payload, (address, uint256));
        // _mint(to, amount);
    }

    function setRaffleTradeFee(uint256 _newTradeFee) external onlyOwner {
        raffleTradeFee = _newTradeFee;
    }

    function getTotalPrice(uint _itemId) public view returns (uint) {
        return ((items[_itemId].price * (HUNDRED_PERCENT + raffleTradeFee)) /
            HUNDRED_PERCENT);
    }

    function getAllListedNfts() external view returns (Item[] memory) {
        Item[] memory nfts = new Item[](activeItemCount);
        uint256 totalCount = itemCount;
        uint256 nftCount = 0;
        for (uint i = 0; i < totalCount; i++) {
            Item memory item = items[i + 1];
            if (!item.sold) {
                nfts[nftCount] = item;
                nftCount++;
            }
        }
        return nfts;
    }
}
