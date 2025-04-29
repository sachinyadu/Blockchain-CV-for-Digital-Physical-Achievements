// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AchievementCV
 * @dev Smart contract that allows users to maintain a CV of verified achievements on the blockchain
 */
contract AchievementCV {
    // Achievement structure
    struct Achievement {
        string title;
        string description;
        string issuer;
        uint256 timestamp;
        string achievementURI; // URI to metadata/certificate
        bool isPhysical; // Whether it's a physical or digital achievement
        bool isVerified; // Whether the achievement has been verified by the issuer
    }
    
    // Mapping from user address to their achievements
    mapping(address => Achievement[]) public userAchievements;
    
    // Mapping of authorized issuers (address => authorized status)
    mapping(address => bool) public authorizedIssuers;
    
    // Contract owner
    address public owner;
    
    // Events
    event AchievementAdded(address indexed user, uint256 achievementIndex, string title);
    event AchievementVerified(address indexed user, uint256 achievementIndex);
    event IssuerAuthorized(address indexed issuer);
    event IssuerDeauthorized(address indexed issuer);
    
    // Constructor
    constructor() {
        owner = msg.sender;
        authorizedIssuers[msg.sender] = true; // Contract creator is an authorized issuer
    }
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Only authorized issuers can perform this action");
        _;
    }
    
    /**
     * @dev Adds a new achievement to a user's CV
     * @param _title The title of the achievement
     * @param _description Description of the achievement
     * @param _issuer Name of the issuing organization
     * @param _achievementURI URI to achievement metadata/certificate
     * @param _isPhysical Whether the achievement is physical or digital
     */
    function addAchievement(
        string memory _title,
        string memory _description,
        string memory _issuer,
        string memory _achievementURI,
        bool _isPhysical
    ) public {
        Achievement memory newAchievement = Achievement({
            title: _title,
            description: _description,
            issuer: _issuer,
            timestamp: block.timestamp,
            achievementURI: _achievementURI,
            isPhysical: _isPhysical,
            isVerified: false
        });
        
        userAchievements[msg.sender].push(newAchievement);
        emit AchievementAdded(msg.sender, userAchievements[msg.sender].length - 1, _title);
    }
    
    /**
     * @dev Verify an achievement (only authorized issuers)
     * @param _user Address of the user whose achievement needs verification
     * @param _achievementIndex Index of the achievement to verify
     */
    function verifyAchievement(address _user, uint256 _achievementIndex) public onlyAuthorizedIssuer {
        require(_achievementIndex < userAchievements[_user].length, "Achievement does not exist");
        
        userAchievements[_user][_achievementIndex].isVerified = true;
        emit AchievementVerified(_user, _achievementIndex);
    }
    
    /**
     * @dev Authorize or deauthorize an issuer (only owner)
     * @param _issuer Address of the issuer
     * @param _status Authorization status to set
     */
    function setIssuerAuthorization(address _issuer, bool _status) public onlyOwner {
        authorizedIssuers[_issuer] = _status;
        
        if (_status) {
            emit IssuerAuthorized(_issuer);
        } else {
            emit IssuerDeauthorized(_issuer);
        }
    }
    
    /**
     * @dev Get all achievements for a user
     * @param _user Address of the user
     * @return Array of all achievements for the user
     */
    function getUserAchievements(address _user) public view returns (Achievement[] memory) {
        return userAchievements[_user];
    }
}
