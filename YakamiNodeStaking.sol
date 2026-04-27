// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ==============================================
// 1. TOKEN ERC-20 (YAK-Energy)
// ==============================================
contract YakEnergy {
    string public name = "Yakami Energy Token";
    string public symbol = "YAK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        totalSupply = 1_000_000 * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Saldo insuficiente");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Saldo insuficiente");
        require(allowance[from][msg.sender] >= value, "Allowance insuficiente");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function mint(address to, uint256 amount) public {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}

// ==============================================
// 2. NFT ERC-721 (YAK-Device) - Identidade do Hardware
// ==============================================
contract YakDevice {
    string public name = "Yakami Device Identity";
    string public symbol = "YAKDEV";
    
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => string) public pufHashOf;    // Hash do Chip PUF
    mapping(uint256 => uint256) public timestampOf;
    
    uint256 public nextTokenId;
    address public minter;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event DeviceMinted(uint256 indexed tokenId, string pufHash, address indexed operator);
    
    constructor() {
        minter = msg.sender;
    }
    
    modifier onlyMinter() {
        require(msg.sender == minter, "Apenas o minter autorizado");
        _;
    }
    
    function mintDevice(address to, string memory pufHash) external onlyMinter returns (uint256) {
        uint256 tokenId = nextTokenId++;
        ownerOf[tokenId] = to;
        balanceOf[to]++;
        pufHashOf[tokenId] = pufHash;
        timestampOf[tokenId] = block.timestamp;
        
        emit Transfer(address(0), to, tokenId);
        emit DeviceMinted(tokenId, pufHash, to);
        
        return tokenId;
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == from, "Nao e o proprietario");
        require(to != address(0), "Endereco invalido");
        
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        
        emit Transfer(from, to, tokenId);
    }
    
    function getDevice(uint256 tokenId) external view returns (string memory pufHash, address owner, uint256 timestamp) {
        return (pufHashOf[tokenId], ownerOf[tokenId], timestampOf[tokenId]);
    }
}

// ==============================================
// 3. STAKING COM SLASHING (Garantia de Honestidade)
// ==============================================
contract YakamiNodeStaking {
    
    YakEnergy public yakEnergy;
    YakDevice public yakDevice;
    
    address public admin;
    
    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 lastReward;
        uint256 slashCount;
        bool active;
    }
    
    mapping(address => StakeInfo) public stakes;
    mapping(uint256 => address) public deviceToOperator;
    mapping(address => uint256[]) public operatorDevices;
    
    uint256 public rewardRate = 100;    // 100 YAK por ano por 1000 stake
    uint256 public slashingPenalty = 20; // 20% de corte
    
    event Staked(address indexed operator, uint256 amount);
    event Unstaked(address indexed operator, uint256 amount);
    event RewardPaid(address indexed operator, uint256 reward);
    event Slashed(address indexed operator, uint256 penalty, string reason);
    event DeviceRegistered(uint256 indexed deviceId, address indexed operator);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Apenas admin");
        _;
    }
    
    constructor(address _yakEnergy, address _yakDevice) {
        admin = msg.sender;
        yakEnergy = YakEnergy(_yakEnergy);
        yakDevice = YakDevice(_yakDevice);
    }
    
    function stake(uint256 amount) external {
        require(amount > 0, "Valor invalido");
        yakEnergy.transferFrom(msg.sender, address(this), amount);
        
        StakeInfo storage info = stakes[msg.sender];
        if (info.amount > 0) {
            _claimReward(msg.sender);
        }
        
        info.amount += amount;
        info.timestamp = block.timestamp;
        info.active = true;
        
        emit Staked(msg.sender, amount);
    }
    
    function unstake(uint256 amount) external {
        StakeInfo storage info = stakes[msg.sender];
        require(info.amount >= amount, "Saldo insuficiente");
        
        _claimReward(msg.sender);
        info.amount -= amount;
        yakEnergy.transfer(msg.sender, amount);
        
        if (info.amount == 0) {
            info.active = false;
        }
        
        emit Unstaked(msg.sender, amount);
    }
    
    function claimReward() external {
        _claimReward(msg.sender);
    }
    
    function _claimReward(address operator) internal {
        StakeInfo storage info = stakes[operator];
        if (info.amount == 0) return;
        
        uint256 duration = block.timestamp - info.lastReward;
        uint256 reward = (info.amount * rewardRate * duration) / (1000 * 365 days);
        
        if (reward > 0) {
            info.lastReward = block.timestamp;
            yakEnergy.mint(operator, reward);
            emit RewardPaid(operator, reward);
        }
    }
    
    // ⚠️ FUNÇÃO CRÍTICA: Slashing em caso de fraude
    function slash(address operator, string memory reason) external onlyAdmin {
        StakeInfo storage info = stakes[operator];
        require(info.active, "Operador nao ativo");
        
        uint256 penalty = (info.amount * slashingPenalty) / 100;
        info.amount -= penalty;
        info.slashCount++;
        
        // Penalidade é queimada (enviada para address(0))
        yakEnergy.transfer(address(0), penalty);
        
        emit Slashed(operator, penalty, reason);
    }
    
    function registerDevice(uint256 deviceId, address operator) external onlyAdmin {
        require(deviceToOperator[deviceId] == address(0), "Dispositivo ja registrado");
        require(stakes[operator].active, "Operador sem stake ativo");
        require(yakDevice.ownerOf(deviceId) == operator, "Operador nao e dono do NFT");
        
        deviceToOperator[deviceId] = operator;
        operatorDevices[operator].push(deviceId);
        
        emit DeviceRegistered(deviceId, operator);
    }
    
    function getPendingReward(address operator) public view returns (uint256) {
        StakeInfo storage info = stakes[operator];
        if (info.amount == 0) return 0;
        uint256 duration = block.timestamp - info.lastReward;
        return (info.amount * rewardRate * duration) / (1000 * 365 days);
    }
    
    function getOperatorDevices(address operator) external view returns (uint256[] memory) {
        return operatorDevices[operator];
    }
}

// ==============================================
// 4. DAO TÉCNICA (Hardware Governance)
// ==============================================
contract YakamiHardwareDAO {
    
    YakDevice public yakDevice;
    address public admin;
    
    struct Proposal {
        string description;
        uint256 newRewardRate;
        uint256 newMinPingTime;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 createdAt;
        address proposer;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    
    uint256 public rewardRate = 100;
    uint256 public minPingTime = 300; // 5 minutos
    
    event ProposalCreated(uint256 indexed id, string description, address proposer);
    event Voted(address indexed voter, uint256 indexed id, bool support);
    event ParameterUpdated(string param, uint256 newValue);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Apenas admin");
        _;
    }
    
    modifier onlyDeviceHolder() {
        require(yakDevice.balanceOf(msg.sender) > 0, "Apenas holders de dispositivo");
        _;
    }
    
    constructor(address _yakDevice) {
        admin = msg.sender;
        yakDevice = YakDevice(_yakDevice);
    }
    
    function createProposal(string memory description, uint256 newRewardRate, uint256 newMinPingTime) 
        external 
        onlyDeviceHolder 
    {
        proposals[proposalCount] = Proposal({
            description: description,
            newRewardRate: newRewardRate,
            newMinPingTime: newMinPingTime,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            createdAt: block.timestamp,
            proposer: msg.sender
        });
        
        emit ProposalCreated(proposalCount, description, msg.sender);
        proposalCount++;
    }
    
    function vote(uint256 proposalId, bool support) external onlyDeviceHolder {
        require(!hasVoted[msg.sender][proposalId], "Ja votou");
        require(!proposals[proposalId].executed, "Proposta ja executada");
        
        hasVoted[msg.sender][proposalId] = true;
        uint256 weight = 1; // Um dispositivo, um voto
        
        if (support) {
            proposals[proposalId].votesFor += weight;
        } else {
            proposals[proposalId].votesAgainst += weight;
        }
        
        emit Voted(msg.sender, proposalId, support);
    }
    
    function executeProposal(uint256 proposalId) external onlyAdmin {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Ja executada");
        require(p.votesFor > p.votesAgainst, "Proposta rejeitada");
        
        p.executed = true;
        rewardRate = p.newRewardRate;
        minPingTime = p.newMinPingTime;
        
        emit ParameterUpdated("rewardRate", rewardRate);
        emit ParameterUpdated("minPingTime", minPingTime);
    }
    
    function getProposalStatus(uint256 proposalId) external view returns (
        string memory description,
        uint256 votesFor,
        uint256 votesAgainst,
        bool executed,
        address proposer
    ) {
        Proposal memory p = proposals[proposalId];
        return (p.description, p.votesFor, p.votesAgainst, p.executed, p.proposer);
    }
}