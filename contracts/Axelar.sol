pragma solidity ^0.8.10;

import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {StringToAddress, AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol";
import "./interface/IWrappedToken.sol";

contract Axelar is AxelarExecutable {
    using StringToAddress for string;
    using AddressToString for address;
    IAxelarGasService public immutable gasService;
    mapping(string => address) public sourceChains;
    IWrappedToken public immutable i_wrappedNativeToken;
    string public symbol;
    event ReceivedData(
        string sourceChain,
        string sourceAddress,
        uint256 testData1,
        address testAddress1,
        address testAddress2
    );
    event ReceivedDataWithToken(
        string sourceChain,
        string sourceAddress,
        string tokenSymbol,
        uint256 amount,
        uint256 testData1,
        address testAddress1,
        address testAddress2
    );

    constructor(
        address _gateway,
        IAxelarGasService _gasService,
        IWrappedToken _wrappedNativeToken,
        string memory _symbol
    ) AxelarExecutable(_gateway) {
        gasService = _gasService;
        i_wrappedNativeToken = _wrappedNativeToken;
        symbol = _symbol;
    }

    function addSourceChain(
        string calldata _sourceChain,
        address _sourceChainAddress
    ) external {
        require(
            _sourceChainAddress != address(0),
            "Invalid source chain address"
        );
        require(bytes(_sourceChain).length > 0, "Invalid source chain");
        sourceChains[_sourceChain] = _sourceChainAddress;
    }

    function makeCrossChainCall(
        string calldata destinationChain,
        string calldata destinationAddress,
        uint _totalPrice,
        address seller
    ) public payable {
        bytes memory payload = abi.encode(_totalPrice, msg.sender, seller);
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            msg.sender
        );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    function makeCrossChainCallWithToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        uint _totalPrice,
        address seller
    ) public payable {
        i_wrappedNativeToken.deposit{value: _totalPrice}();
        require(
            i_wrappedNativeToken.approve(address(gateway), _totalPrice),
            "failed to approve wrapped native token"
        );
        bytes memory payload = abi.encode(_totalPrice, msg.sender, seller);

        gasService.payNativeGasForContractCallWithToken{
            value: msg.value - _totalPrice
        }(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            symbol,
            _totalPrice,
            msg.sender
        );
        gateway.callContractWithToken(
            destinationChain,
            destinationAddress,
            payload,
            symbol,
            _totalPrice
        );
    }

    function _execute(
        string calldata _sourceChain,
        string calldata _sourceAddress,
        bytes calldata payload
    ) internal override {
        require(
            sourceChains[_sourceChain] == _sourceAddress.toAddress(),
            "Invalid source chain or address"
        );
        (uint testData1, address testAddress1, address testAddress2) = abi
            .decode(payload, (uint, address, address));

        emit ReceivedData(
            _sourceChain,
            _sourceAddress,
            testData1,
            testAddress1,
            testAddress2
        );
    }

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        require(
            sourceChains[sourceChain] == sourceAddress.toAddress(),
            "Invalid source chain or address"
        );
        (uint testData1, address testAddress1, address testAddress2) = abi
            .decode(payload, (uint, address, address));

        emit ReceivedDataWithToken(
            sourceChain,
            sourceAddress,
            tokenSymbol,
            amount,
            testData1,
            testAddress1,
            testAddress2
        );
    }
}
