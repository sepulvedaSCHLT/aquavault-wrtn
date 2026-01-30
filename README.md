# AQUAVAULT (WRTN)

**AQUAVAULT (WRTN)** is a BEP-20 token on **BNB Smart Chain** focused on **operational transparency** and a phased approach to support **real-world potable water infrastructure** and water reserve initiatives, backed by **public verification** (official links + on-chain evidence).

> **Network:** BNB Smart Chain (BEP-20)  
> **Verified contract:** `0x668aF355D33662C2E0200eBe947db6241D9a906d`  
> **Official website:** https://www.tokenaquavault.com  
> **Whitepaper (PDF):** https://www.tokenaquavault.com/assets/docs/aquapaper-aquavault-wrtn.pdf  
> **Official contact:** https://www.tokenaquavault.com/contact/  
> **Official email:** project.info@tokenaquavault.com  

---

## Quick Verification (BscScan / Public Links)

- **BscScan (Contract):** https://bscscan.com/address/0x668aF355D33662C2E0200eBe947db6241D9a906d  
- **Documentation hub:** https://www.tokenaquavault.com/documentation/  
- **Project page:** https://www.tokenaquavault.com/project/  
- **Whitepaper (PDF):** https://www.tokenaquavault.com/assets/docs/aquapaper-aquavault-wrtn.pdf  
- **Official contact:** https://www.tokenaquavault.com/contact/  
- **GitHub repository:** https://github.com/sepulvedaSCHLT/aquavault-wrtn  
- **X (Project):** https://x.com/AQUAVAULT_WRTN  
- **LinkedIn (Project):** https://www.linkedin.com/company/aquavault-wrtn  

> Keep all official links consistent across the website, GitHub, and public profiles to support external verification.

---

## Mission (High-Level)

AQUAVAULT (WRTN) was created to connect **digital traceability** with **real-world water impact** through phased execution. The blockchain layer is used to:
- publish verifiable references,
- keep documentation publicly accessible,
- and enable transparent review of contract behavior and administrative actions via on-chain state and events.

This repository is part of that verification layer.

---

## Repository Structure

- `contracts/` — smart contract source code (single-file implementation for Remix deploy & BscScan verification).
- `docs/` — AQUAPAPER (GitHub readable whitepaper) and supporting documentation.
- `assets/` — public assets used by the project (if applicable).

---

## Smart Contract Summary (Based on the Verified Code)

### Token metadata
- **Name:** AQUAVAULT  
- **Symbol:** WRTN  
- **Decimals:** 18  

### Supply
- **Max supply cap (hard-coded):** `200,000,000 WRTN` (18 decimals)
- The contract mints the full cap at deployment to the **owner**.
- **Owner-controlled mint exists** but cannot exceed `MAX_SUPPLY`.
- **Owner-controlled burn** reduces total supply.

### Transfer fee (basis points)
- Transfer fee is configurable via `setFeeBps()` and routed to `feeRecipient`.
- **Hard cap by code:** `MAX_FEE_BPS = 300` (3.00%)
- Fee can be set to `0` (disabled).
- Fee exemptions supported: `isFeeExempt`.

### Max wallet limit (anti-whale)
- Configurable max wallet via `setMaxWalletBps()`.
- **Hard cap by code:** `HARD_CAP_WALLET_BPS = 3000` (30.00%)
- Max wallet amount is dynamic: `maxWalletAmount()` uses `totalSupply` (changes after burns).
- Exemptions supported: `isMaxWalletExempt`.

### Safety controls
- **Pause / Unpause**: callable by `owner` or `emergencyManager`.
- **Strict pause behavior**: while paused, only the **owner** can move tokens.
- **Freeze list**: owner can block transfers from/to frozen addresses (`isFrozen`).

### Events
Administrative changes emit events (fee changes, max wallet changes, emergency manager update, freeze, pause/unpause), supporting public review through BscScan.

---

## Operational Policy (Phased Execution)

AQUAVAULT follows a staged approach:
1. **Foundation:** verified contract, public documentation, official channels.
2. **Market readiness:** liquidity planning and public disclosure of relevant policies (e.g., custody/LP approach when applicable).
3. **Execution milestones:** real-world water initiatives with evidence releases (reports, links, and verifiable references where appropriate).
4. **Scaling:** automation of transparency reporting and broader integrations.

This describes operational intent and does not imply guaranteed outcomes.

---

## Documentation

- **AQUAPAPER (GitHub Whitepaper):** `docs/whitepaper_aquavault_wrtn_oficial.md`  
- **Whitepaper (PDF):** https://www.tokenaquavault.com/assets/docs/aquapaper-aquavault-wrtn.pdf  
- **Documentation page:** https://www.tokenaquavault.com/documentation/  

---

## Contact & Official Channels

- **Contact form:** https://www.tokenaquavault.com/contact/  
- **Email:** project.info@tokenaquavault.com  
- **X (Project):** https://x.com/AQUAVAULT_WRTN  
- **LinkedIn (Project):** https://www.linkedin.com/company/aquavault-wrtn  

---

## Security Notes

This project prioritizes transparency, but avoids publishing sensitive operational details that could increase attack surface (private keys, internal security procedures, etc.). Use on-chain verification and official links for review.

---

## Disclaimer

This repository and its contents are provided for **informational purposes only** and do not constitute financial advice, legal advice, or an offer to invest. Cryptoassets are volatile and involve risk, including the possibility of losing the entire invested capital. Always verify information on-chain and perform your own research (DYOR).

---

## License

Add a `LICENSE` file if you plan to publish the code under an open-source license (e.g., MIT).
