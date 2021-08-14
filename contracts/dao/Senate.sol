// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./interfaces/IERC20.sol";

contract Senate  {

    struct Manager {
        uint256 budget;
        address owner;
    }
        
    Manager tech;
    uint8 public TECH_INDEX = 0;
    Manager community;
    uint8 public COMMUNITY_INDEX = 1;
    Manager business;
    uint8 public BUSINESS_INDEX = 2;
    Manager marketing;
    uint8 public MARKETING_INDEX = 3;
    Manager adoption;
    uint8 public ADOPTION_INDEX = 4;

    // Common struct for a vote, if a manager approve = 1, reject =0
    struct Vote {
        uint8 approve;
        bool voted;
        address manager;
    }
    
    IERC20 public token;

    bool public voting;
    bool public initialized;
    uint256 public nextVotingPeriod;
    uint256 public votingPeriodEnd;
    
    constructor(address _tech, address _community, address _business, address _marketing, address _adoption, address _token) {
        token = IERC20(_token);

        tech = Manager(30, _tech);
        community = Manager(10, _community);
        business = Manager(20, _business);
        marketing = Manager(20, _marketing);
        adoption = Manager(20, _adoption);

        voting = false;
        initialized = false;
        nextVotingPeriod = block.timestamp + 365 days;
    }
    
    // ** View functions ** //

    function getBudgetAllocation() public view returns(uint256, uint256, uint256, uint256, uint256) {
        return (tech.budget, community.budget, business.budget, marketing.budget, adoption.budget);
    }
    
    function getManagersOwner() public view returns(address, address, address, address, address) {
        return (tech.owner, community.owner, business.owner, marketing.owner, adoption.owner);
    }

    // ** Public functions ** //

    uint256 public communitySenateBanTotalLocked;
    mapping (address => uint256) communitySenateBanLocked;

    function initializeFullSenateBan() external {
        uint256 supply = token.totalSupply();
        uint256 minimumRequired = supply * 30 / 100;
        require(communitySenateBanTotalLocked > minimumRequired, "Senate: not enough votes to ban all senate members");
        
        // Deactivate the contract
        deactivate();

        // Start a voting phase
        voting = true;

        // Reinitialize the voting period.
        nextVotingPeriod = block.timestamp;

        // Add 14 days for voting period;
        votingPeriodEnd = block.timestamp + 14 days;

        tech.owner = address(0);
        community.owner = address(0);
        business.owner = address(0);
        marketing.owner = address(0);
        adoption.owner = address(0);
    }

    function withdrawCoinsFromSenateBan() external {
        uint256 lockedCoins = communitySenateBanLocked[msg.sender];
        communitySenateBanTotalLocked = communitySenateBanTotalLocked - (lockedCoins);
        communitySenateBanLocked[msg.sender] = 0;
        token.transfer(msg.sender, lockedCoins);
    }

    function submitSenateBan(uint256 amount) external {
        require(amount != 0, "Senate: cannot submit 0 tokens");
        token.transferFrom(msg.sender, address(this), amount);
        communitySenateBanTotalLocked = communitySenateBanTotalLocked + amount;
        communitySenateBanLocked[msg.sender] = communitySenateBanLocked[msg.sender]  + amount;
    }

    function initializeVotingCycle() external {
        require(block.timestamp > nextVotingPeriod, "Senate: cannot initialize a voting period before the cycle ends");
        // Once the voting cycle is initialized all managers are emptied and the contract is de-initialized;
        tech.owner = address(0);
        community.owner = address(0);
        business.owner = address(0);
        marketing.owner = address(0);
        adoption.owner = address(0);

        deactivate();
        voting = true;

        votingPeriodEnd = block.timestamp  + 14 days;
    }

    struct Candidate {
        uint8 positiong;
        address owner;
        string hashCodeProposal;
    }

    mapping (address => Candidate) techCandidates;
    Candidate[] techCandidatesArr;
    mapping (address => Candidate) communityCandidates;
    Candidate[] communityCandidatesArr;
    mapping (address => Candidate) businessCandidates;
    Candidate[] businessCandidatesArr;
    mapping (address => Candidate) marketingCandidates;
    Candidate[] marketingCandidatesArr;
    mapping (address => Candidate) adoptionCandidates;
    Candidate[] adoptionCandidatesArr;

    mapping (address => Candidate) candidates;

    function submitCandidate(uint8 position, string memory proposal) external {
        require(voting, "Senate: the Senate is not on voting phase");
        require(candidates[msg.sender].owner == address(0), "Senate: unable to upload same candidate twice");
        Candidate memory candidate = Candidate(position, msg.sender, proposal);
        candidates[msg.sender] = candidate;
        if (position == TECH_INDEX) {
            techCandidates[msg.sender] = candidate;
            require(techCandidatesArr.length <= 10, "Senate: already more than 10 tech candidates submited");
            techCandidatesArr.push(candidate);
        } else if (position == COMMUNITY_INDEX) {
            communityCandidates[msg.sender] = candidate;
            require(communityCandidatesArr.length <= 10, "Senate: already more than 10 community candidates submited");
            communityCandidatesArr.push(candidate);
        } else if (position == BUSINESS_INDEX) {
            businessCandidates[msg.sender] = candidate;
            require(businessCandidatesArr.length <= 10, "Senate: already more than 10 business candidates submited");
            businessCandidatesArr.push(candidate);
        } else if (position == MARKETING_INDEX) {
            marketingCandidates[msg.sender] = candidate;
            require(marketingCandidatesArr.length <= 10, "Senate: already more than 10 marketing candidates submited");
            marketingCandidatesArr.push(candidate);
        } else if (position == ADOPTION_INDEX) {
            adoptionCandidates[msg.sender] = candidate;
            require(adoptionCandidatesArr.length <= 10, "Senate: already more than 10 adoption candidates submited");
            adoptionCandidatesArr.push(candidate);
        } else {
            revert("Candidate position is not known");
        }
    }

    mapping (address => uint256) votesLockedTokens;
    uint256 public totalVotesLockedTokens;
    mapping (address => uint256) candidateVotes;

    function finalizeVotingPeriod() external {
        require(block.timestamp >= votingPeriodEnd, "Senate: unable to finish voting period, there is still time to vote");
        
        // Make sure all 5 positions are proposed.
        require(techCandidatesArr.length > 0, "Senate: Unable to close vote, there is no tech candidate");
        require(communityCandidatesArr.length > 0, "Senate: Unable to close vote, there is no community candidate");
        require(businessCandidatesArr.length > 0, "Senate: Unable to close vote, there is no business candidate");
        require(marketingCandidatesArr.length > 0, "Senate: Unable to close vote, there is no marketing candidate");
        require(adoptionCandidatesArr.length > 0, "Senate: Unable to close vote, there is no adoption candidate");

        if (techCandidatesArr.length == 1) {
            require(candidateVotes[techCandidatesArr[0].owner] > 0, "Senate: can't finalize voting because there is only 1 tech candidate with 0 votes");
            // If there is only 1 tech candidate with more than 1 vote, automatically wins.
            tech.owner = techCandidatesArr[0].owner;
        } else {
            Candidate memory choosenCandidate = techCandidatesArr[0];
            for (uint256 i = 1; i < techCandidatesArr.length; i++) {
                uint256 choosenVotes = candidateVotes[choosenCandidate.owner];
                if (candidateVotes[techCandidatesArr[i].owner] > choosenVotes) {
                    choosenCandidate = techCandidatesArr[i];
                }
            }
            tech.owner = choosenCandidate.owner;
        }

        if (communityCandidatesArr.length == 1) {
            require(candidateVotes[communityCandidatesArr[0].owner] > 0, "Senate: can't finalize voting because there is only 1 community candidate with 0 votes");
            // If there is only 1 community candidate with more than 1 vote, automatically wins.
            community.owner = communityCandidatesArr[0].owner;
        } else {
            Candidate memory choosenCandidate = communityCandidatesArr[0];
            for (uint256 i = 1; i < communityCandidatesArr.length; i++) {
                uint256 choosenVotes = candidateVotes[choosenCandidate.owner];
                if (candidateVotes[communityCandidatesArr[i].owner] > choosenVotes) {
                    choosenCandidate = communityCandidatesArr[i];
                }
            }
            community.owner = choosenCandidate.owner;
        }

        if (businessCandidatesArr.length == 1) {
            require(candidateVotes[businessCandidatesArr[0].owner] > 0, "Senate: can't finalize voting because there is only 1 business candidate with 0 votes");
            // If there is only 1 business candidate with more than 1 vote, automatically wins.
            business.owner = businessCandidatesArr[0].owner;
          
        } else {
            Candidate memory choosenCandidate = businessCandidatesArr[0];
            for (uint256 i = 1; i < businessCandidatesArr.length; i++) {
                uint256 choosenVotes = candidateVotes[choosenCandidate.owner];
                if (candidateVotes[businessCandidatesArr[i].owner] > choosenVotes) {
                    choosenCandidate = businessCandidatesArr[i];
                }
            }
            business.owner = choosenCandidate.owner;
        }

        if (marketingCandidatesArr.length == 1) {
            require(candidateVotes[marketingCandidatesArr[0].owner] > 0, "Senate: can't finalize voting because there is only 1 marketing candidate with 0 votes");
            // If there is only 1 marketing candidate with more than 1 vote, automatically wins.
            marketing.owner = marketingCandidatesArr[0].owner;
        } else {
            Candidate memory choosenCandidate = marketingCandidatesArr[0];
            for (uint256 i = 1; i < marketingCandidatesArr.length; i++) {
                uint256 choosenVotes = candidateVotes[choosenCandidate.owner];
                if (candidateVotes[marketingCandidatesArr[i].owner] > choosenVotes) {
                    choosenCandidate = marketingCandidatesArr[i];
                }
            }
            marketing.owner = choosenCandidate.owner;
        }

        if (adoptionCandidatesArr.length == 1) {
            require(candidateVotes[adoptionCandidatesArr[0].owner] > 0, "Senate: can't finalize voting because there is only 1 adoption candidate with 0 votes");
            // If there is only 1 adoption candidate with more than 1 vote, automatically wins.
            adoption.owner = adoptionCandidatesArr[0].owner;
        } else {
            Candidate memory choosenCandidate = adoptionCandidatesArr[0];
            for (uint256 i = 1; i < adoptionCandidatesArr.length; i++) {
                uint256 choosenVotes = candidateVotes[choosenCandidate.owner];
                if (candidateVotes[adoptionCandidatesArr[i].owner] > choosenVotes) {
                    choosenCandidate = adoptionCandidatesArr[i];
                }
            }
            adoption.owner = choosenCandidate.owner;
        }

        voting = false;

        delete techCandidatesArr;
        delete communityCandidatesArr;
        delete businessCandidatesArr;
        delete marketingCandidatesArr;
        delete adoptionCandidatesArr;

        nextVotingPeriod = nextVotingPeriod + 365 days;
    }

    function withdrawVotedCoins() external {
        require(!voting, "Senate: cannot unlock coins until voting phase ends");
        uint256 votedAmount = votesLockedTokens[msg.sender];
        totalVotesLockedTokens = totalVotesLockedTokens - (votedAmount);
        votesLockedTokens[msg.sender] = 0;
        token.transfer(msg.sender, votedAmount);
    }

    function voteCandidate(address _candidate, uint256 amount) external {
        Candidate memory candidate = candidates[_candidate];
        require(candidate.owner != address(0), "Senate: voted candidate is not proposed");
        token.transferFrom(msg.sender, address(this), amount);
        candidateVotes[candidate.owner] = candidateVotes[candidate.owner] + amount;
        votesLockedTokens[msg.sender] = votesLockedTokens[msg.sender] + amount;
        totalVotesLockedTokens = totalVotesLockedTokens + amount;
    }
    
    
    // ** Single Manager functions ** //
    
    function claimBudget() public onlyManager {
        require(initialized, "Senate: contract is not initialized yet");
        uint256 balance = token.balanceOf(address(this));
        uint256 budget = balance - (totalVotesLockedTokens) - (communitySenateBanTotalLocked) - (replacementVotesTotalLocked);
        uint256 techBudget = budget * (tech.budget) / (100);
        uint256 communityBudget = budget * (community.budget) / (100);
        uint256 businessBudget = budget * (business.budget) / (100);
        uint256 marketingBudget = budget * (marketing.budget) / (100);
        uint256 adoptionBudget = budget * (adoption.budget) / (100);
        token.transfer(tech.owner, techBudget);
        token.transfer(community.owner, communityBudget);
        token.transfer(business.owner, businessBudget);
        token.transfer(marketing.owner, marketingBudget);
        token.transfer(adoption.owner, adoptionBudget);
    }
    
    
    // ** Modifiers ** //
    
    modifier onlyManager() {
        require(isManager(), "Senate: sender is not a manager");
        _;
    }
    
    function isManager() public view returns (bool) {
        address sender = msg.sender;
        if (sender == tech.owner || sender == community.owner || sender == business.owner || sender == marketing.owner || sender == adoption.owner) {
            return true;
        }
        return false;
    }
    
    function getManager() internal view returns (Manager memory) {
        address sender = msg.sender;
        if (sender == tech.owner) {
            return tech;
        } else if (sender == community.owner) {
            return community;
        } else if (sender == business.owner) {
            return business;
        } else if (sender == marketing.owner) {
            return marketing;
        } else if (sender == adoption.owner) {
            return adoption;
        } else {
            revert("Sender is not a manager");
        }
    }
    
    // ** Multi-votes functions ** //
    
    mapping(address => bool) initialization_votes;
    address[]  initialization_votes_arr;
    
    function initialize() public onlyManager {
        Manager memory manager = getManager();
        require(manager.owner != address(0), "Senate: no address manager");
        require(!initialization_votes[manager.owner], "Senate: manager already initialized");
        initialization_votes[manager.owner] = true;
        initialization_votes_arr.push(manager.owner);
        if (initialization_votes_arr.length == 5) {
            initialized = true;
        }
    }

    function deactivate() internal {
        for (uint256 i = 0; i < initialization_votes_arr.length; i++) {
            initialization_votes[initialization_votes_arr[i]] = false;
        }
        delete initialization_votes_arr;
        initialized = false;
    }
    
    uint256[] proposedBudgetAllocation;
    mapping(address => Vote) approve_new_proposed_budget_allocation;
    Vote[] approve_new_proposed_budget_allocation_arr;
    
    function getProposedBudgetAllocation() public view returns(uint256, uint256, uint256, uint256, uint256) {
        if (proposedBudgetAllocation.length == 5) {
            return (proposedBudgetAllocation[0], proposedBudgetAllocation[1], proposedBudgetAllocation[2], proposedBudgetAllocation[3], proposedBudgetAllocation[4]);
        } else {
            return (0,0,0,0,0);
        }
    }
        
    function voteNewBudgetAllocation(uint8 approve) public onlyManager {
        Manager memory manager = getManager();
        require(manager.owner != address(0), "Senate: no address manager");
        require(!approve_new_proposed_budget_allocation[manager.owner].voted, "Senate: manager already voted");
        Vote memory vote = Vote(approve, true, msg.sender);
        approve_new_proposed_budget_allocation[manager.owner] = vote;
        approve_new_proposed_budget_allocation_arr.push(vote);
        _changeBudgetAllocation();
    }
    
    function _changeBudgetAllocation() internal {
        if (approve_new_proposed_budget_allocation_arr.length == 5) {
            
            // Check for the managers votes if at least 3 out of 5 vote for the new budget, transition it.
            uint256 approvals = 0;
            for (uint256 i = 0; i < approve_new_proposed_budget_allocation_arr.length; i++) {
                
                if (approve_new_proposed_budget_allocation_arr[i].approve == 1) {
                    approvals++;
                }
                
                // Once the vote is counted, reset the votes mapping
                approve_new_proposed_budget_allocation[approve_new_proposed_budget_allocation_arr[i].manager] = Vote(0, false, address(0));
            }
            
            if (approvals >= 3) {
                tech.budget = proposedBudgetAllocation[TECH_INDEX];
                community.budget = proposedBudgetAllocation[COMMUNITY_INDEX];
                business.budget = proposedBudgetAllocation[BUSINESS_INDEX];
                marketing.budget = proposedBudgetAllocation[MARKETING_INDEX];
                adoption.budget = proposedBudgetAllocation[ADOPTION_INDEX];
            }
            
            delete approve_new_proposed_budget_allocation_arr;
            delete proposedBudgetAllocation;
        } 
    }
    
    function proposeNewBudgetAllocation(uint256[] memory new_budget_allocation) public onlyManager {
        require(approve_new_proposed_budget_allocation_arr.length == 0, "Senate: cannot propose a new budget allocation during a voting of a new allocation");
        uint256 sum = 0;
        for (uint256 i = 0; i < new_budget_allocation.length; i++) {
            sum = sum + new_budget_allocation[i];
        }
        require(sum == 100, "Senate: Error trying to add a budget allocation proposal: budget should sum 100 percent");
        proposedBudgetAllocation = new_budget_allocation;
    }

    struct ManagementReplacement {
        uint256 position;
        address owner;
    }

    mapping (address => Vote) manager_replacement_votes;
    Vote[] manager_replacement_votes_arr;
    ManagementReplacement proposed_manager_replacement;

    mapping (address => uint256) replacementVotesTokensLocked;
    uint256 public replacementVotesTotalLocked;
    uint256 public communityReplacementVoteInitialTime;
    uint256 communityReplacementVotePeriod = 7 days;
    
    function executeReplacementVote() external {
        require(block.timestamp > communityReplacementVoteInitialTime + communityReplacementVotePeriod, "Senate: there is still time to vote before the replacement");
        require(replacementVotesTotalLocked > 0, "Senate: no one has voted for manager replacement");
        uint256 supply = token.totalSupply();
        uint256 minimum = supply * (10) / (100);

        if (replacementVotesTotalLocked > minimum) {
            if (proposed_manager_replacement.position == TECH_INDEX) {
                tech.owner = proposed_manager_replacement.owner;
            } else if (proposed_manager_replacement.position == COMMUNITY_INDEX) {
                community.owner = proposed_manager_replacement.owner;
            } else if (proposed_manager_replacement.position == BUSINESS_INDEX) {
                business.owner = proposed_manager_replacement.owner;
            } else if (proposed_manager_replacement.position == MARKETING_INDEX) {
                marketing.owner = proposed_manager_replacement.owner;
            } else if (proposed_manager_replacement.position == ADOPTION_INDEX) {
                adoption.owner = proposed_manager_replacement.owner;
            }
            
            deactivate();
        } 

        communityReplacementVoteInitialTime = 0;
        delete manager_replacement_votes_arr;
        proposed_manager_replacement.position = 0;
        proposed_manager_replacement.owner = address(0);
    }

    function withdrawTokensForReplacementVote() external {
        uint256 lockedTokens = replacementVotesTokensLocked[msg.sender];
        replacementVotesTotalLocked = replacementVotesTotalLocked - (lockedTokens);
        replacementVotesTokensLocked[msg.sender] = 0;
        token.transfer(msg.sender, lockedTokens);
    }

    function submitApprovalForVoteReplacement(uint256 amount) external {
        require(amount != 0, "Senate: cannot submit approval with 0 tokens");
        token.transferFrom(msg.sender, address(this), amount);
        replacementVotesTokensLocked[msg.sender] = replacementVotesTokensLocked[msg.sender] + amount;
        replacementVotesTotalLocked = replacementVotesTotalLocked + amount;
    }

    function voteManagementReplacement(uint8 approve) public onlyManager {
        Manager memory manager = getManager();
        require(manager.owner != address(0), "Senate: no address manager");
        require(!manager_replacement_votes[msg.sender].voted, "Senate: manager already voted");
        Vote memory vote = Vote(approve, true, msg.sender);
        manager_replacement_votes[msg.sender] = vote;
        manager_replacement_votes_arr.push(vote);
        _replaceManager();
    }
    
    function _replaceManager() internal {
        if (manager_replacement_votes_arr.length == 5) {
            uint256 approvals = 0;

            for (uint256 i = 0; i < manager_replacement_votes_arr.length; i++) {
                
                if (manager_replacement_votes_arr[i].approve == 1) {
                    approvals++;
                }
                
                // Once the vote is counted, reset the votes mapping
                manager_replacement_votes[manager_replacement_votes_arr[i].manager] = Vote(0, false, address(0));
            }

                // If there is a full Senate approval, the replacement should be submitted
            if (approvals == 5) {
                if (proposed_manager_replacement.position == TECH_INDEX) {
                    tech.owner = proposed_manager_replacement.owner;
                } else if (proposed_manager_replacement.position == COMMUNITY_INDEX) {
                    community.owner = proposed_manager_replacement.owner;
                } else if (proposed_manager_replacement.position == BUSINESS_INDEX) {
                    business.owner = proposed_manager_replacement.owner;
                } else if (proposed_manager_replacement.position == MARKETING_INDEX) {
                    marketing.owner = proposed_manager_replacement.owner;
                } else if (proposed_manager_replacement.position == ADOPTION_INDEX) {
                    adoption.owner = proposed_manager_replacement.owner;
                }

                deactivate();

                delete manager_replacement_votes_arr;
                proposed_manager_replacement.position = 0;
                proposed_manager_replacement.owner = address(0);

            } else if (approvals >= 3) {
                // If only 3 out of 5 senate members approve it, it should be submited to the community
                // Community has 1 week to vote with at least 10% of the total supply to confirm.
                communityReplacementVoteInitialTime = block.timestamp;

            } else {

                // If there is nothing else, remove the proposal.
                delete manager_replacement_votes_arr;
                proposed_manager_replacement.position = 0;
                proposed_manager_replacement.owner = address(0);

            }
            
        }
    }

    function proposeManagementReplace(uint8 _position, address _newManager) public onlyManager {
        require(manager_replacement_votes_arr.length == 0, "Senate: cannot propose a manager replacement during the voting of a managemer replacement");
        proposed_manager_replacement.position = _position;
        proposed_manager_replacement.owner = _newManager;
    }
    
}
