// TASK - MANAGERS
// Manager in Lake Contract is someone, who manages certain consents - this manager is usually a trust entity that can add people to certain owned consents
// please review the following code and make changes to make the code fully working
// 1. We have a function to updateManager - this function works with _managersToConsents and _managers in order to log active managers and to which consents is a certain manager; these variables need to change accordingly to changes pushed to updateManager function
// 2. We have some basic queries to see active managers, to check if a certain address is a manages and which consents does a certain manager manage (by address again)
// 3. We have a function _isManagerAllowedToChangeConsents -- what is its exact goal? is the function written properly? describe, fix, explain the code

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

//Added imported files from OpenZeppelin and created my own Interafce

import "@openzeppelin/contracts/access/Ownable.sol";

interface IManagers {
    event ManagerWithConsentsChanged(address, uint32[], address);
    function updateManager(address manager, uint32[] memory consentsIds) external;
    function getManagers() external view returns (address[] memory);
    function isManager(address manager) external view  returns (bool);
    function getManagerConsents(address manager) external view returns (uint32[] memory); 

}

contract Managers is IManagers, Ownable {

    mapping(address => uint32[]) private _managersToConsents;
    
    address[] private _managers;


    //Adding new mapping for looking exist consents in the future.
    mapping(uint32 => bool) private consentsExist;

    //If you will send empty array it means manager no longer active, we delete all consents and manager from active
    //If you will send some array, we will add new consents additionally to exsiting consents.
    //We will check is it available to change any consents.
    function updateManager(address manager, uint32[] memory consentsIds) external onlyOwner override {
        if (consentsIds.length == 0) {
            for (uint i=0; i<_managers.length; i++) {
                if (_managers[i] == manager) {
                    for (uint y=0; y<_managersToConsents[_managers[i]].length; y++) {
                        delete consentsExist[_managersToConsents[_managers[i]][y]];
                    }
                    delete _managers[i];
                    break;
                }
            }
            delete _managersToConsents[manager];
        } else {
            require(_isManagerAllowedToChangeConsents(consentsIds), "This manager not allowed to change consets");
            for (uint i=0; i<consentsIds.length; i++) {
                _managersToConsents[manager].push(consentsIds[i]);
                consentsExist[consentsIds[i]] = true;
            }
            if (!isManager(manager)){
                _managers.push(manager);
            }
        }

        emit ManagerWithConsentsChanged(manager, _managersToConsents[manager], _msgSender());
    }
        
    function getManagers() external view override returns (address[] memory) {
        return _managers;
    }

    function isManager(address manager) public view override returns (bool) {
        for (uint i = 0; i < _managers.length; i++) {
            if (_managers[i] == manager) {
                return true;
                }
            }
            return false;
    }

    function getManagerConsents(address manager) external view override returns (uint32[] memory) {        
        return _managersToConsents[manager];
    }



    //I decide to change this function totally
    //We will look is any requested conesents already exist or not. If it is exist, we will not allow.
    //I made suggestion one consents only for one manager
    //But we could discuss it here more, for ex add more logs, or another logic.
    //Anyway, previous code was not really good.
    function _isManagerAllowedToChangeConsents(uint32[] memory consentsIds) internal view returns (bool allowed) {
        for (uint i=0; i<consentsIds.length; i++) {
            if (consentsExist[consentsIds[i]]) {
                allowed = false;
                break;
            }
            allowed = true;
        }
    }
}
