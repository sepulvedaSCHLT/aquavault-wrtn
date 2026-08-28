# AQUAVAULT (WRTN)

A BEP-20 token contract on BNB Smart Chain, written from scratch in
Solidity 0.8.20 and deployed to mainnet. Administrative limits are enforced
by immutable constants in the contract rather than by policy, so any third
party can verify the constraints by reading the verified source.

**Verified contract:** [`0x668aF355D33662C2E0200eBe947db6241D9a906d`](https://bscscan.com/address/0x668aF355D33662C2E0200eBe947db6241D9a906d)
**Network:** BNB Smart Chain (BEP-20) · **Compiler:** 0.8.20 · **License:** MIT

---

## Repository

| Path | Contents |
|---|---|
| [`contracts/TokenAquaVault_V1.sol`](contracts/TokenAquaVault_V1.sol) | Full contract source (single file, deployed and verified) |
| [`docs/whitepaper_aquavault_wrtn_oficial.md`](docs/whitepaper_aquavault_wrtn_oficial.md) | Technical documentation (AQUAPAPER) |
| `assets/` | Project logo assets |

---

## Design Decisions

**Hard caps live in code, not in a document.**
`MAX_SUPPLY`, `MAX_FEE_BPS` (300 = 3.00%) and `HARD_CAP_WALLET_BPS`
(3000 = 30.00%) are `constant`. The owner can tune `feeBps` and
`maxWalletBps` below those ceilings but cannot exceed them under any
circumstance. The limit is not a promise — it is unreachable code paths.

**Max wallet is derived, not stored.**
`maxWalletAmount()` computes against current `_totalSupply` on every call
rather than caching an absolute value. After a burn reduces supply, the cap
stays proportionally correct instead of silently becoming a larger share of
a smaller supply.

**The receiver is checked post-fee, not pre-fee.**
`_transfer` validates `_balances[to] + received <= maxWalletAmount()` using
the amount actually credited after fee deduction. Checking the gross amount
would reject transfers that are in fact compliant.

**Emergency authority is split from ownership.**
`pause()`/`unpause()` are guarded by `onlyOwnerOrEmergency`, so a dedicated
`emergencyManager` address can halt transfers during an incident without
holding mint, burn, or parameter-setting rights. Incident response does not
require bringing the owner key online.

**Strict pause.**
While `paused`, `_transfer` permits movement only when `from == owner`.
A partial pause that still allows some transfers is a false sense of safety.

**Burn actually reduces supply.**
`_burn` decrements `_totalSupply`. Transferring to the `DEAD` address does
not, and the contract does not present it as if it did — a distinction many
token contracts blur.

**Every administrative change emits an event.**
`FeeBpsUpdated`, `MaxWalletBpsUpdated`, `EmergencyManagerUpdated`,
`FrozenUpdated`, `Paused`/`Unpaused`, `FeeExemptUpdated`,
`MaxWalletExemptUpdated`. Admin history is reconstructible from logs alone,
which is what makes external verification possible.

---

## Contract Interface

**Standard ERC-20:** `totalSupply` · `balanceOf` · `transfer` · `approve` ·
`allowance` · `transferFrom` · `increaseAllowance` · `decreaseAllowance`

**Owner-only:** `mint` (capped at `MAX_SUPPLY`) · `burn` · `setFeeBps` ·
`setMaxWalletBps` · `setFeeRecipient` · `setFeeExempt` ·
`setMaxWalletExempt` · `setFrozen` · `setEmergencyManager` ·
`transferOwnership`

**Owner or emergency manager:** `pause` · `unpause`

**Public view:** `maxWalletAmount()`

---

## Security Model

| Control | Mechanism |
|---|---|
| Supply inflation | `mint` reverts above `MAX_SUPPLY` |
| Fee abuse | `setFeeBps` reverts above `MAX_FEE_BPS` (3%) |
| Concentration | Post-transfer receiver check against `maxWalletAmount()` |
| Incident response | `pause` / `unpause`, callable by owner or emergency manager |
| Targeted response | `isFrozen` blocks transfers to and from an address |
| Reentrancy | No external calls in the transfer path |

### Trust assumptions

Stated plainly, because a security section that only lists protections is
marketing: the owner is privileged. The owner can mint up to the cap, burn,
freeze arbitrary addresses, set fee exemptions, and move tokens while
paused. The hard caps bound *how far* that privilege reaches; they do not
remove it. Anyone evaluating this contract should read
`contracts/TokenAquaVault_V1.sol` directly.

### Note on the ERC-20 implementation

The token implements ERC-20 directly rather than inheriting OpenZeppelin.
This was a deliberate choice to keep the deployed bytecode to a single
auditable file with no inherited surface, at the cost of not benefiting
from OpenZeppelin's review history. For most production work I would
recommend OpenZeppelin; this repository documents the trade-off rather
than hiding it.

---

## Project Context

AQUAVAULT (WRTN) was built to explore whether on-chain traceability can be
tied to verifiable real-world reporting — specifically, potable water
infrastructure — through phased execution and public evidence rather than
promised outcomes. Full rationale, tokenomics and roadmap are in
[the AQUAPAPER](docs/whitepaper_aquavault_wrtn_oficial.md).

The project is currently paused. The contract remains deployed and
verified on-chain.

---

## License

MIT — see [LICENSE](LICENSE).

---

## Disclaimer

This repository is provided for informational purposes only. It is not
financial or legal advice and not an offer to invest. No returns are
promised. Cryptoassets are volatile and carry risk including total loss of
capital. Verify all information on-chain before acting on it.
