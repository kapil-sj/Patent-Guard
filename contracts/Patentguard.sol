// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Patent Guard - Innovation Registration System
 * @dev A decentralized system to register and verify ownership of innovations.
 *      Innovators can register their inventions with metadata and proof of creation.
 */

contract PatentGuard {
    // Structure to represent a registered innovation
    struct Innovation {
        uint256 id;
        string title;
        string description;
        string documentHash; // IPFS or hash of patent document
        address owner;
        uint256 timestamp;
    }

    // Mappings and counters
    uint256 private innovationCounter;
    mapping(uint256 => Innovation) private innovations;
    mapping(address => uint256[]) private ownerInnovations;

    // Events
    event InnovationRegistered(
        uint256 indexed id,
        address indexed owner,
        string title,
        uint256 timestamp
    );

    event OwnershipTransferred(
        uint256 indexed id,
        address indexed oldOwner,
        address indexed newOwner
    );

    event InnovationUpdated(
        uint256 indexed id,
        string newTitle,
        string newDescription,
        uint256 timestamp
    );

    /**
     * @notice Register a new innovation
     * @param _title The title of the innovation
     * @param _description A short description
     * @param _documentHash Hash or IPFS CID of the innovation document
     */
    function registerInnovation(
        string calldata _title,
        string calldata _description,
        string calldata _documentHash
    ) external {
        innovationCounter++;
        innovations[innovationCounter] = Innovation({
            id: innovationCounter,
            title: _title,
            description: _description,
            documentHash: _documentHash,
            owner: msg.sender,
            timestamp: block.timestamp
        });

        ownerInnovations[msg.sender].push(innovationCounter);

        emit InnovationRegistered(innovationCounter, msg.sender, _title, block.timestamp);
    }

    /**
     * @notice Transfer ownership of an innovation to another address
     * @param _innovationId The ID of the innovation
     * @param _newOwner The new owner's address
     */
    function transferOwnership(uint256 _innovationId, address _newOwner) external {
        require(_newOwner != address(0), "Invalid new owner");
        Innovation storage innovation = innovations[_innovationId];
        require(innovation.owner == msg.sender, "Only the owner can transfer ownership");

        address oldOwner = innovation.owner;
        innovation.owner = _newOwner;

        emit OwnershipTransferred(_innovationId, oldOwner, _newOwner);
    }

    /**
     * @notice Retrieve details of a specific innovation
     * @param _innovationId The ID of the innovation
     * @return Innovation details
     */
    function getInnovation(uint256 _innovationId)
        external
        view
        returns (Innovation memory)
    {
        return innovations[_innovationId];
    }

    /**
     * @notice Get all innovations registered by an address
     * @param _owner Address of the innovator
     * @return Array of innovation IDs
     */
    function getInnovationsByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return ownerInnovations[_owner];
    }

    /**
     * @notice Update innovation title and description
     * @param _innovationId The ID of the innovation to update
     * @param _newTitle New title
     * @param _newDescription New description
     */
    function updateInnovationDetails(
        uint256 _innovationId,
        string calldata _newTitle,
        string calldata _newDescription
    ) external {
        Innovation storage innovation = innovations[_innovationId];
        require(innovation.owner == msg.sender, "Only the owner can update details");

        innovation.title = _newTitle;
        innovation.description = _newDescription;
        innovation.timestamp = block.timestamp;

        emit InnovationUpdated(_innovationId, _newTitle, _newDescription, block.timestamp);
    }

    /**
     * @notice Verify if an address is the current owner of an innovation
     * @param _innovationId Innovation ID to verify
     * @param _address Address to check
     * @return True if the address is the current owner
     */
    function verifyOwnership(uint256 _innovationId, address _address)
        external
        view
        returns (bool)
    {
        return innovations[_innovationId].owner == _address;
    }
}
