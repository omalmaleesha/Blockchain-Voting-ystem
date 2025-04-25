// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VotingSystem {
    enum ElectionState { NotStarted, InProgress, Ended }
    
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        bytes32 voteHash; // Hashed vote for privacy
    }
    
    struct Election {
        string title;
        ElectionState state;
        uint startTime;
        uint endTime;
        mapping(address => Voter) voters;
        Candidate[] candidates;
        bool isPaused;
    }
    
    address public admin;
    mapping(uint => Election) public elections;
    uint public electionCount;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter(uint electionId) {
        require(elections[electionId].voters[msg.sender].isRegistered, "Not a registered voter");
        _;
    }
    
    modifier electionInProgress(uint electionId) {
        require(elections[electionId].state == ElectionState.InProgress, "Election not in progress");
        require(!elections[electionId].isPaused, "Election is paused");
        require(block.timestamp >= elections[electionId].startTime, "Election not started yet");
        require(block.timestamp <= elections[electionId].endTime, "Election has ended");
        _;
    }
    
    event ElectionCreated(uint electionId, string title, uint startTime, uint endTime);
    event VoterRegistered(uint electionId, address voter);
    event CandidateAdded(uint electionId, uint candidateId, string name);
    event VoteCast(uint electionId, address voter);
    event ElectionStateChanged(uint electionId, ElectionState state);
    event ElectionPaused(uint electionId, bool isPaused);
    
    constructor() {
        admin = msg.sender;
    }
    
    // Admin creates a new election
    function createElection(string memory title, uint durationInSeconds) public onlyAdmin {
        Election storage election = elections[electionCount];
        election.title = title;
        election.state = ElectionState.NotStarted;
        election.startTime = block.timestamp;
        election.endTime = block.timestamp + durationInSeconds;
        election.isPaused = false;
        
        emit ElectionCreated(electionCount, title, election.startTime, election.endTime);
        electionCount++;
    }
    
    // Admin adds a candidate to an election
    function addCandidate(uint electionId, string memory name) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(elections[electionId].state == ElectionState.NotStarted, "Election already started");
        
        Election storage election = elections[electionId];
        uint candidateId = election.candidates.length;
        election.candidates.push(Candidate(candidateId, name, 0));
        
        emit CandidateAdded(electionId, candidateId, name);
    }
    
    // Admin registers a voter
    function registerVoter(uint electionId, address voter) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(!elections[electionId].voters[voter].isRegistered, "Voter already registered");
        
        elections[electionId].voters[voter] = Voter(true, false, bytes32(0));
        emit VoterRegistered(electionId, voter);
    }
    
    // Admin starts the election
    function startElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(elections[electionId].state == ElectionState.NotStarted, "Election already started");
        
        elections[electionId].state = ElectionState.InProgress;
        emit ElectionStateChanged(electionId, ElectionState.InProgress);
    }
    
    // Admin ends the election
    function endElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(elections[electionId].state == ElectionState.InProgress, "Election not in progress");
        
        elections[electionId].state = ElectionState.Ended;
        emit ElectionStateChanged(electionId, ElectionState.Ended);
    }
    
    // Admin pauses or unpauses the election
    function togglePauseElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(elections[electionId].state == ElectionState.InProgress, "Election not in progress");
        
        elections[electionId].isPaused = !elections[electionId].isPaused;
        emit ElectionPaused(electionId, elections[electionId].isPaused);
    }
    
    // Voter casts a vote
    function castVote(uint electionId, uint candidateId, bytes32 voteHash) public onlyRegisteredVoter(electionId) electionInProgress(electionId) {
        Election storage election = elections[electionId];
        require(!election.voters[msg.sender].hasVoted, "Voter has already voted");
        require(candidateId < election.candidates.length, "Invalid candidate ID");
        
        election.voters[msg.sender].hasVoted = true;
        election.voters[msg.sender].voteHash = voteHash;
        election.candidates[candidateId].voteCount++;
        
        emit VoteCast(electionId, msg.sender);
    }
    
    // Voter verifies their vote
    function verifyVote(uint electionId, bytes32 voteHash) public view returns (bool) {
        require(electionId < electionCount, "Invalid election ID");
        return elections[electionId].voters[msg.sender].voteHash == voteHash;
    }
    
    // Get election details
    function getElection(uint electionId) public view returns (
        string memory title,
        ElectionState state,
        uint startTime,
        uint endTime,
        bool isPaused,
        uint candidateCount
    ) {
        require(electionId < electionCount, "Invalid election ID");
        Election storage election = elections[electionId];
        return (
            election.title,
            election.state,
            election.startTime,
            election.endTime,
            election.isPaused,
            election.candidates.length
        );
    }
    
    // Get candidate details
    function getCandidate(uint electionId, uint candidateId) public view returns (
        uint id,
        string memory name,
        uint voteCount
    ) {
        require(electionId < electionCount, "Invalid election ID");
        require(candidateId < elections[electionId].candidates.length, "Invalid candidate ID");
        Candidate memory candidate = elections[electionId].candidates[candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    // Get voter status
    function getVoterStatus(uint electionId, address voter) public view returns (
        bool isRegistered,
        bool hasVoted
    ) {
        require(electionId < electionCount, "Invalid election ID");
        Voter memory voterInfo = elections[electionId].voters[voter];
        return (voterInfo.isRegistered, voterInfo.hasVoted);
    }
}