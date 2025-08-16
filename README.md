EscrowVault Smart Contract

The **EscrowVault** smart contract is a decentralized escrow system built on the Stacks blockchain. It enables users to securely lock STX in escrow until predefined conditions are met, ensuring **trustless and transparent fund transfers** between parties.

---

Features
- **Secure Fund Locking** — Lock STX into escrow agreements.  
- **Multi-Party Support** — Supports agreements between multiple participants.  
- **Condition-Based Release** — Funds are released only when agreed-upon conditions are fulfilled.  
- **Event Logging** — Transparent record of deposits, releases, and escrow lifecycle.  
- **Trustless Execution** — Eliminates the need for third-party intermediaries.  

---

 Contract Functions
- `create-escrow` → Initializes a new escrow agreement.  
- `deposit` → Deposit STX into the escrow.  
- `release-funds` → Releases escrowed funds to the beneficiary when conditions are met.  
- `cancel-escrow` → Allows safe cancellation and refund of funds (under specific conditions).  

---

 Deployment
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/escrow-vault.git
   ```bash
cd escrow-vault
   ```bash
clarinet deploy
