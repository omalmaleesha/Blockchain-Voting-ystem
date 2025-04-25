# 🗳️ Blockchain Voting System

## 🧾 Overview

This project is a **decentralized voting system** built with **Solidity** on the **Ethereum blockchain**. It ensures a **secure**, **transparent**, and **tamper-proof** voting process with features like voter registration, encrypted voting, time-bound elections, and auditability.

---

## 🚀 Features

- **🔐 Role-Based Access Control** – Admin manages the system; voters and candidates have defined roles.
- **🧍 Voter Registration** – Only admin-registered voters can participate.
- **🔒 Vote Encryption** – Votes are stored as **hashed values** for privacy.
- **⏳ Time-Bound Voting** – Elections run within a predefined window.
- **✅ Vote Verification** – Voters can verify if their vote was recorded.
- **📊 Auditability** – Public can view final tallies without revealing identities.
- **👤 Candidate Management** – Admin adds candidates before voting starts.
- **📌 Immutable Vote Recording** – Votes are stored immutably on the blockchain.
- **🛑 Emergency Stop** – Admin can pause/resume an election.
- **📢 Event Logging** – Key actions emit events for transparency and off-chain tracking.

---

## 🏗️ Contract Structure

### `Election`
- Title
- Status: `NotStarted`, `InProgress`, `Ended`
- Start and End timestamps
- Pause status

### `Candidate`
- Candidate ID
- Name
- Vote count

### `Voter`
- Registration status
- Voting status
- Hashed vote

### `Admin`
- Responsible for:
  - Creating elections
  - Adding candidates
  - Registering voters
  - Managing election state

---

## 🔧 Key Functions

| Function            | Description |
|---------------------|-------------|
| `createElection`    | Admin creates a new election with title & duration |
| `addCandidate`      | Admin adds a candidate before election starts |
| `registerVoter`     | Admin registers a voter |
| `startElection`     | Starts the election |
| `castVote`          | Voter submits hashed vote |
| `verifyVote`        | Voter verifies vote was recorded |
| `endElection`       | Admin ends the election |
| `togglePauseElection` | Pause/resume the election |
| `getElection`       | View election details |
| `getCandidate`      | View candidate info |
| `getVoterStatus`    | Check voter registration/vote status |

---

## 🧪 Usage

### 🛠️ Deploy the Contract

Deploy the `VotingSystem.sol` contract on any Ethereum-compatible blockchain (e.g., Ganache, Goerli testnet).

### 👨‍💼 Admin Actions

1. `createElection` – Start a new election.
2. `addCandidate` – Add candidates before the election starts.
3. `registerVoter` – Register eligible voters.
4. `startElection` – Begin the election process.

### 🧑‍💻 Voter Actions

- `castVote` – Submit a hashed vote.
- `verifyVote` – Confirm that the vote was recorded.

### 🌐 Public Actions

- `getElection`, `getCandidate`, `getVoterStatus` – View transparent, non-sensitive election data.

### ⚙️ Admin Management

- `togglePauseElection` – Temporarily pause the election.
- `endElection` – Close the voting process.

---

## 🛡️ Security Considerations

- **Strict Access Control** – Only admin can manage elections, voters, and candidates.
- **Vote Privacy** – Vote hashes protect anonymity.
- **Time-Limited Voting** – Enforced by smart contract logic.
- **Immutability** – Votes cannot be altered once recorded.
- **Emergency Pause** – Admin can halt voting in case of technical issues.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
See the [LICENSE](LICENSE) file for more details.

---

## 🙏 Acknowledgments

- **Three.js Community** – Inspiration for 3D frontends (if used)
- **CDN Providers** – For hosting any external libraries
- **Astronomy Enthusiasts** – For inspiring decentralized science and transparency

---

## 📬 Contact

Have suggestions or questions?  
Open an issue or email the maintainer at: **omalmaleesha03@gmail.com**

> **Secure. Transparent. Immutable. Let the people vote!**
