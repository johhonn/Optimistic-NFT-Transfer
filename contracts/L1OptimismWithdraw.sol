// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.7.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title [L1] ERC1155 token that represents an IOU withdrawal that can be redeemed for a certian amount of an ERC20 on L1.
/// @dev You need to deploy a L1 broker contract that will be authorized to mint the tokens.
contract L1OptimismWithdraw is ERC721 {
    /// @dev Stores the underlying ERC20s on L1 and L2.
    /// @dev The l1ERC20 property is the address of the token (on L1) the l2ERC20 has told us it will unwrap to (this is not guaranteed which is why we store the l2ERC20 so users can choose if they trust the token).
    /// @dev The l2ERC20 proprety is the address of the token on L2 that the L2Checkpoint initiated a withdraw on.
    /// @dev The l1Bank property is the address that will approve `amount` of their `l1ERC20` tokens to `recipient` on L1.
    struct Metadata {
        address l1ERC721;
        address l2ERC721;
        address l1Bank;
    }

    /// @notice Maps token IDs to the address of the underlying ERC20s.
    mapping(uint256 => Metadata) public metadata;

    /// @dev The address of the L1Broker that is allowed to call the burn() and mint() functions on this contract.
    address internal l1Broker;

    /// @notice Creates a new L1OptimismWithdraw ERC1155 token and authorizes the given l1Broker to mint and burn tokens.
    /// @param _l1Broker The address of the L1Broker contract you want to be authorized to call the methods on this contract.
    constructor(address _l1Broker)
        ERC721("Texel","TT")
    {
        l1Broker = _l1Broker;
    }

    modifier onlyBroker {
        require(
            msg.sender == l1Broker,
            "Only the broker can call this function."
        );
        _;
    }

    function burn(
        
        uint256 id
    ) external onlyBroker {
        _burn(id);
    }

    /// @notice Mints `amount` of a token with the `id` to the `recipient` and links it to an underlying ERC20.
    /// @param id The ID of the token that will be created and given to the `recipient`
    /// @param recipient The address of the user who will recieve the tokens.
    /// @param l1ERC721 The address of the token (on L1) the l2ERC20 has told us it will unwrap to (this is not guaranteed which is why we store the l2ERC20 so users can choose if they trust the token).
    /// @param l2ERC721 The address of the token on L2 that the L2Checkpoint initiated a withdraw on.
    /// @param l1Bank The address that will approve `amount` of their `l1ERC20` tokens to `recipient` on L1.
    
    function mint(
        uint256 id,
        address recipient,
        address l1ERC721,
        address l2ERC721,
        address l1Bank
        
    ) external onlyBroker {
        metadata[id] = Metadata(l1ERC721, l2ERC721, l1Bank);
        _mint(recipient, id);
    }
}
