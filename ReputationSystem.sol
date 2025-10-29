// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Decentralized Identity & Reputation
 * @notice A minimal smart contract to manage verifiable achievements and reputation scores on-chain.
 * @dev Designed for educational/hackathon demonstration purposes.
 */
contract ReputationSystem {
    struct User {
        uint256 reputation;
        bool registered;
    }

    mapping(address => User) public users;
    address public admin;

    event Registered(address indexed user);
    event AchievementVerified(address indexed user, string achievement, uint256 reputationGained);
    event ReputationStaked(address indexed user, uint256 amount, string reason);
    event ReputationReduced(address indexed user, uint256 amount, string reason);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a new user to the reputation system
    function register() external {
        require(!users[msg.sender].registered, "Already registered");
        users[msg.sender] = User(0, true);
        emit Registered(msg.sender);
    }

    /// @notice Called by organizers to verify achievements and award reputation
    /// @param user The address of the user being verified
    /// @param achievement Description of the verified achievement
    /// @param reputationPoints Number of points to award
    function verifyAchievement(address user, string memory achievement, uint256 reputationPoints) external onlyAdmin {
        require(users[user].registered, "User not registered");
        users[user].reputation += reputationPoints;
        emit AchievementVerified(user, achievement, reputationPoints);
    }

    /// @notice Allows a user to stake part of their reputation for an action
    /// @param amount The amount of reputation to risk
    /// @param reason The reason or context of staking (e.g., "collaboration", "proposal")
    function stakeReputation(uint256 amount, string memory reason) external {
        require(users[msg.sender].registered, "User not registered");
        require(users[msg.sender].reputation >= amount, "Not enough reputation");
        users[msg.sender].reputation -= amount; // Burn staked rep if they cheat (simplified)
        emit ReputationStaked(msg.sender, amount, reason);
    }

    /// @notice Allows anyone to view the reputation score of a user
    /// @param user The address of the user
    /// @return The reputation score of that user
    function getReputation(address user) external view returns (uint256) {
        require(users[user].registered, "User not registered");
        return users[user].reputation;
    }

    /// @notice Admin can reduce reputation for cheating or misconduct
    /// @param user The address of the user to penalize
    /// @param amount The amount of reputation to deduct
    /// @param reason The reason for reduction
    function reduceReputation(address user, uint256 amount, string memory reason) external onlyAdmin {
        require(users[user].registered, "User not registered");
        require(users[user].reputation >= amount, "Insufficient reputation to reduce");
        users[user].reputation -= amount;
        emit ReputationReduced(user, amount, reason);
    }
}
