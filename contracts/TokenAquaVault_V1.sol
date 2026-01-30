
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * AQUAVAULT (WRTN) - BEP-20 style token for BSC
 * - Max supply: 200,000,000 WRTN (18 decimals)
 * - Transfer fee (bps) sent to feeRecipient
 * - Max wallet limit (bps) with hard cap 30%
 * - Owner-controlled mint (only up to MAX_SUPPLY) and burn
 * - Emergency pause/unpause (owner or emergencyManager)
 * - Optional freeze list (owner)
 *
 * NOTE: This is a single-file implementation to simplify Remix deploy & BscScan verification.
 */
contract AQUAVAULT {
    // -------------------------
    // ERC20 metadata
    // -------------------------
    string public constant name = "AQUAVAULT";
    string public constant symbol = "WRTN";
    uint8 public constant decimals = 18;

    // -------------------------
    // Supply
    // -------------------------
    uint256 public constant MAX_SUPPLY = 200_000_000 * 1e18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // -------------------------
    // Roles / control
    // -------------------------
    address public owner;
    address public emergencyManager;

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    modifier onlyOwnerOrEmergency() {
        require(msg.sender == owner || msg.sender == emergencyManager, "NOT_AUTH");
        _;
    }

    // -------------------------
    // Safety controls
    // -------------------------
    bool public paused;
    mapping(address => bool) public isFrozen;

    // -------------------------
    // Fee & limits (basis points)
    // -------------------------
    // basis points: 10,000 = 100%
    uint16 public feeBps;               // e.g., 150 = 1.5%
    uint16 public maxWalletBps;         // e.g., 600 = 6%
    address public feeRecipient;

    uint16 public constant MAX_FEE_BPS = 300;          // hard cap: 3.00%
    uint16 public constant HARD_CAP_WALLET_BPS = 3000; // hard cap: 30.00%

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isMaxWalletExempt;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // -------------------------
    // Events
    // -------------------------
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event EmergencyManagerUpdated(address indexed previousManager, address indexed newManager);

    event Paused(address indexed by);
    event Unpaused(address indexed by);

    event FeeRecipientUpdated(address indexed previousRecipient, address indexed newRecipient);
    event FeeBpsUpdated(uint16 previousBps, uint16 newBps);
    event MaxWalletBpsUpdated(uint16 previousBps, uint16 newBps);

    event FeeExemptUpdated(address indexed account, bool isExempt);
    event MaxWalletExemptUpdated(address indexed account, bool isExempt);

    event FrozenUpdated(address indexed account, bool frozen);

    // -------------------------
    // Constructor
    // -------------------------
    /**
     * @param owner_           Owner address (can be different from deployer)
     * @param feeRecipient_    Address that receives transfer fees
     * @param emergency_       Emergency manager for pause/unpause
     * @param initialFeeBps    Initial fee in bps (150 = 1.5%)
     * @param initialMaxBps    Initial max wallet in bps (600 = 6%)
     */
    constructor(
        address owner_,
        address feeRecipient_,
        address emergency_,
        uint16 initialFeeBps,
        uint16 initialMaxBps
    ) {
        require(owner_ != address(0), "OWNER_0");
        require(feeRecipient_ != address(0), "FEE_RECIPIENT_0");
        require(emergency_ != address(0), "EMERGENCY_0");
        require(initialFeeBps <= MAX_FEE_BPS, "FEE_TOO_HIGH");
        require(initialMaxBps <= HARD_CAP_WALLET_BPS, "MAXWALLET_TOO_HIGH");

        owner = owner_;
        feeRecipient = feeRecipient_;
        emergencyManager = emergency_;

        feeBps = initialFeeBps;
        maxWalletBps = initialMaxBps;

        // Exemptions (recommended defaults)
        isFeeExempt[owner_] = true;
        isFeeExempt[feeRecipient_] = true;
        isFeeExempt[address(this)] = true;

        isMaxWalletExempt[owner_] = true;
        isMaxWalletExempt[feeRecipient_] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[DEAD] = true;

        // Mint full supply to owner
        _mint(owner_, MAX_SUPPLY);

        emit OwnershipTransferred(address(0), owner_);
        emit FeeRecipientUpdated(address(0), feeRecipient_);
        emit EmergencyManagerUpdated(address(0), emergency_);
        emit FeeBpsUpdated(0, initialFeeBps);
        emit MaxWalletBpsUpdated(0, initialMaxBps);
    }

    // -------------------------
    // ERC20 standard
    // -------------------------
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) external view returns (uint256) { return _balances[account]; }
    function allowance(address tokenOwner, address spender) external view returns (uint256) { return _allowances[tokenOwner][spender]; }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 current = _allowances[from][msg.sender];
        require(current >= amount, "ALLOWANCE_LOW");
        unchecked { _allowances[from][msg.sender] = current - amount; }
        emit Approval(from, msg.sender, _allowances[from][msg.sender]);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 added) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + added);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtracted) external returns (bool) {
        uint256 current = _allowances[msg.sender][spender];
        require(current >= subtracted, "ALLOWANCE_LOW");
        unchecked { _approve(msg.sender, spender, current - subtracted); }
        return true;
    }

    // -------------------------
    // Owner / Emergency controls
    // -------------------------
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "NEW_OWNER_0");
        address prev = owner;
        owner = newOwner;

        // Keep sensible defaults: new owner exempt
        isFeeExempt[newOwner] = true;
        isMaxWalletExempt[newOwner] = true;

        emit OwnershipTransferred(prev, newOwner);
    }

    function setEmergencyManager(address newManager) external onlyOwner {
        require(newManager != address(0), "MANAGER_0");
        address prev = emergencyManager;
        emergencyManager = newManager;
        emit EmergencyManagerUpdated(prev, newManager);
    }

    function pause() external onlyOwnerOrEmergency {
        require(!paused, "ALREADY_PAUSED");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwnerOrEmergency {
        require(paused, "NOT_PAUSED");
        paused = false;
        emit Unpaused(msg.sender);
    }

    // -------------------------
    // Parameters
    // -------------------------
    function setFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "RECIPIENT_0");
        address prev = feeRecipient;
        feeRecipient = newRecipient;

        // recommended exemptions
        isFeeExempt[newRecipient] = true;
        isMaxWalletExempt[newRecipient] = true;

        emit FeeRecipientUpdated(prev, newRecipient);
    }

    function setFeeBps(uint16 newFeeBps) external onlyOwner {
        require(newFeeBps <= MAX_FEE_BPS, "FEE_TOO_HIGH");
        uint16 prev = feeBps;
        feeBps = newFeeBps;
        emit FeeBpsUpdated(prev, newFeeBps);
    }

    function setMaxWalletBps(uint16 newMaxWalletBps) external onlyOwner {
        require(newMaxWalletBps <= HARD_CAP_WALLET_BPS, "MAXWALLET_TOO_HIGH");
        uint16 prev = maxWalletBps;
        maxWalletBps = newMaxWalletBps;
        emit MaxWalletBpsUpdated(prev, newMaxWalletBps);
    }

    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptUpdated(account, exempt);
    }

    function setMaxWalletExempt(address account, bool exempt) external onlyOwner {
        isMaxWalletExempt[account] = exempt;
        emit MaxWalletExemptUpdated(account, exempt);
    }

    function setFrozen(address account, bool frozen) external onlyOwner {
        isFrozen[account] = frozen;
        emit FrozenUpdated(account, frozen);
    }

    // -------------------------
    // Mint / Burn (owner, capped)
    // -------------------------
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "TO_0");
        require(_totalSupply + amount <= MAX_SUPPLY, "MAX_SUPPLY_EXCEEDED");
        _mint(to, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(owner, amount);
    }

    // -------------------------
    // Views
    // -------------------------
    function maxWalletAmount() public view returns (uint256) {
        // dynamic with totalSupply (after burns)
        return (_totalSupply * uint256(maxWalletBps)) / 10_000;
    }

    // -------------------------
    // Internal ERC20 logic
    // -------------------------
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "OWNER_0");
        require(spender != address(0), "SPENDER_0");
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "FROM_0");
        require(to != address(0), "TO_0");
        require(amount > 0, "AMOUNT_0");
        require(!isFrozen[from] && !isFrozen[to], "FROZEN");

        if (paused) {
            // strict pause: only owner can move tokens while paused
            require(from == owner, "PAUSED");
        }

        uint256 fromBal = _balances[from];
        require(fromBal >= amount, "BAL_LOW");
        unchecked { _balances[from] = fromBal - amount; }

        uint256 received = amount;

        // fee
        if (feeBps != 0 && !isFeeExempt[from] && !isFeeExempt[to]) {
            uint256 fee = (amount * uint256(feeBps)) / 10_000;
            if (fee != 0) {
                received = amount - fee;
                _balances[feeRecipient] += fee;
                emit Transfer(from, feeRecipient, fee);
            }
        }

        // max wallet check on receiver (post-transfer)
        if (!isMaxWalletExempt[to]) {
            require(_balances[to] + received <= maxWalletAmount(), "MAX_WALLET");
        }

        _balances[to] += received;
        emit Transfer(from, to, received);
    }

    function _mint(address to, uint256 amount) internal {
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "FROM_0");
        uint256 bal = _balances[from];
        require(bal >= amount, "BAL_LOW");
        unchecked { _balances[from] = bal - amount; }
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}
