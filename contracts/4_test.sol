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

        bool hasCommitted; // Indicates if the voter has committed their vote
        bool hasRevealed;  // Indicates if the voter has revealed their vote
        bytes32 commitment; // Hashed commitment for privacy

    }
    
    struct Election {
        string title;
        ElectionState state;
        uint startTime;
        uint endTime;

        uint revelationPeriod; // Duration for vote revelation after election ends


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

    event ElectionCreated(uint electionId, string title, uint startTime, uint endTime, uint revelationPeriod);
    event VoterRegistered(uint electionId, address voter);
    event CandidateAdded(uint electionId, uint candidateId, string name);
    event VoteCommitted(uint electionId, address voter);
    event VoteRevealed(uint electionId, address voter, uint candidateId);


    event ElectionStateChanged(uint electionId, ElectionState state);
    event ElectionPaused(uint electionId, bool isPaused);
    
    constructor() {
        admin = msg.sender;
    }
 

    // Admin creates a new election with a revelation period
    function createElection(string memory title, uint durationInSeconds, uint revelationPeriodInSeconds) public onlyAdmin {


        Election storage election = elections[electionCount];
        election.title = title;
        election.state = ElectionState.NotStarted;
        election.startTime = block.timestamp;
        election.endTime = block.timestamp + durationInSeconds;

        election.revelationPeriod = revelationPeriodInSeconds;
        election.isPaused = false;
        
        emit ElectionCreated(electionCount, title, election.startTime, election.endTime, revelationPeriodInSeconds);


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


        elections[electionId].voters[voter] = Voter(true, false, false, bytes32(0));

        emit VoterRegistered(electionId, voter);
    }
    
    // Admin starts the election
    function startElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        require(elections[electionId].state == ElectionState.NotStarted, "Election already started");
        
        elections[electionId].state = ElectionState.InProgress;
        emit ElectionStateChanged(electionId, ElectionState.InProgress);
    }
    

    // Admin ends the election after the revelation phase
    function endElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        Election storage election = elections[electionId];
        require(election.state == ElectionState.InProgress, "Election not in progress");
        require(block.timestamp > election.endTime + election.revelationPeriod, "Revelation phase not ended");
        
        election.state = ElectionState.Ended;
        emit ElectionStateChanged(electionId, ElectionState.Ended);
    }
    
    // Admin pauses or unpauses the election (only during commitment phase)
    function togglePauseElection(uint electionId) public onlyAdmin {
        require(electionId < electionCount, "Invalid election ID");
        Election storage election = elections[electionId];
        require(election.state == ElectionState.InProgress, "Election not in progress");
        require(block.timestamp <= election.endTime, "Cannot pause during revelation phase");
        
        election.isPaused = !election.isPaused;
        emit ElectionPaused(electionId, election.isPaused);
    }
    
    // Voter commits their vote during the election
    function castVote(uint electionId, bytes32 commitment) public onlyRegisteredVoter(electionId) electionInProgress(electionId) {
        Election storage election = elections[electionId];
        Voter storage voter = election.voters[msg.sender];
        require(!voter.hasCommitted, "Voter has already committed a vote");
        
        voter.hasCommitted = true;
        voter.commitment = commitment;
        
        emit VoteCommitted(electionId, msg.sender);
    }
    
    // Voter reveals their vote after the election ends
    function revealVote(uint electionId, uint candidateId, bytes32 nonce) public {
        require(electionId < electionCount, "Invalid election ID");
        Election storage election = elections[electionId];
        require(election.state == ElectionState.InProgress, "Election not in progress");
        require(block.timestamp > election.endTime, "Revelation phase not started");
        require(block.timestamp <= election.endTime + election.revelationPeriod, "Revelation phase ended");
        
        Voter storage voter = election.voters[msg.sender];
        require(voter.isRegistered, "Not a registered voter");
        require(voter.hasCommitted, "Voter has not committed a vote");
        require(!voter.hasRevealed, "Voter has already revealed their vote");
        
        bytes32 computedCommitment = keccak256(abi.encode(candidateId, nonce));
        require(computedCommitment == voter.commitment, "Invalid revelation");
        
        // Increment the vote count for the candidate
        require(candidateId < election.candidates.length, "Invalid candidate ID");
        election.candidates[candidateId].voteCount++;
        voter.hasRevealed = true;
        
        emit VoteRevealed(electionId, msg.sender, candidateId);
    }
    
    // Voter verifies their commitment
    function verifyCommitment(uint electionId, bytes32 commitment) public view returns (bool) {
        require(electionId < electionCount, "Invalid election ID");
        return elections[electionId].voters[msg.sender].commitment == commitment;


    }
    
    // Get election details
    function getElection(uint electionId) public view returns (
        string memory title,
        ElectionState state,
        uint startTime,
        uint endTime,

        uint revelationPeriod,


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


            election.revelationPeriod,


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

        bool hasCommitted,
        bool hasRevealed
    ) {
        require(electionId < electionCount, "Invalid election ID");
        Voter memory voterInfo = elections[electionId].voters[voter];
        return (voterInfo.isRegistered, voterInfo.hasCommitted, voterInfo.hasRevealed);


    }
}