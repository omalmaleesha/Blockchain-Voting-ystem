# 📦 Blockchain-Powered Supply Chain Tracker

A decentralized supply chain tracking system built using **Solidity** and deployed on the **Ethereum blockchain**. This project enables tracking of goods from the manufacturer to the retailer, ensuring transparency, security, and immutability at every stage.

---

## 🚀 Features

- ✅ Product creation by manufacturers.
- 🔄 Role-based supply chain flow: **Manufacturer → Supplier → Distributor → Retailer**.
- 📜 Immutable on-chain logs of product movement.
- 🔐 Role-based access control for secure operations.

---

## 🛠️ Tech Stack

- **Solidity** (Smart Contracts)
- **Ethereum Blockchain**
- **Remix IDE** for development and testing

---

## 🧱 Smart Contract Overview

### Product Lifecycle States

```solidity
enum State { Created, Supplied, Distributed, Retailed }
