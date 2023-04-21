// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;
    uint256 public required;

    mapping(uint256 => mapping(address => bool)) public confirmations;

    Transaction[] public transactions;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    modifier onlyOwners() {
        bool isOwner;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) isOwner = true;
        }
        require(isOwner);

        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > _required);
        require(_owners.length > 0);
        require(_required > 0);

        owners = _owners;
        required = _required;
    }

    receive() external payable {}

    function transactionCount() public view returns (uint sigCount) {
        sigCount = transactions.length;
    }

    function addTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) internal returns (uint256) {
        transactions.push(Transaction(_to, _value, _data, false));
        return transactionCount() - 1;
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public {
        uint256 txId = addTransaction(_to, _value, _data);
        confirmTransaction(txId);
    }

    function confirmTransaction(uint txId) public onlyOwners {
        confirmations[txId][msg.sender] = true;
        if (getConfirmationsCount(txId) >= required) {
            executeTransaction(txId);
        }
    }

    function getConfirmationsCount(
        uint txId
    ) public view returns (uint256 sigCount) {
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[txId][owners[i]]) sigCount += 1;
        }
    }

    function isConfirmed(uint txId) public view returns (bool) {
        return getConfirmationsCount(txId) == required;
    }

    function executeTransaction(uint txId) public {
        require(isConfirmed(txId));

        Transaction memory _txInfo = transactions[txId];
        require(!_txInfo.executed);
        transactions[txId].executed = true;

        (bool s, ) = payable(_txInfo.to).call{value: _txInfo.value}(
            _txInfo.data
        );

        require(s);
    }
}
