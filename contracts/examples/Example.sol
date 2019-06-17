pragma solidity ^0.5.8;
import "../token/ZapToken.sol";
import "../platform/bondage/Bondage.sol";
import "../platform/bondage/BondageInterface.sol";
import "../lib/ownership/ZapCoordinatorInterface.sol";
import "../platform/dispatch/DispatchInterface.sol";

contract Example {
    DispatchInterface dispatch;
    BondageInterface bondage;
    ZapCoordinatorInterface coordinator;
    ZapToken zapToken;


    string public whatsUp = "What's up";

    bytes32 public endpoint;
    address public provider;
    address public zapTokenAddress;
    address public bondageAddress;
    address public owner;
    event Results(string response1, string response2, string response3, string response4);

    constructor(address _zapCoor, address _provider, bytes32 _endpoint) public {
        coordinator = ZapCoordinatorInterface(_zapCoor);
        address dispatchAddress = coordinator.getContract("DISPATCH");
        bondageAddress = coordinator.getContract("BONDAGE");
        zapTokenAddress = coordinator.getContract("ZAP_TOKEN");
        bondage = BondageInterface(bondageAddress);
        dispatch = DispatchInterface(dispatchAddress);
        zapToken = ZapToken(zapTokenAddress);
        owner = msg.sender;
        endpoint = _endpoint;
        provider = _provider;
    }

    function allocateZap(uint256 amount) public {
        zapToken.allocate(owner, amount);
    }

    function approve(uint256 amount) public returns (bool) {
        return zapToken.approve(bondageAddress,amount);
    }

    function bond(uint256 dots) public returns (uint256) {
        return bondage.bond(provider,endpoint,dots);
    }

    function unbond(uint256 dots) public returns (uint256) {
        return bondage.unbond(provider,endpoint,dots);
    }


    function callback(uint256 id, string calldata response1) external {
        emit Results(response1, "NOTAVAILABLE", "NOTAVAILABLE", "NOTAVAILABLE");
    }

    function testQuery(address oracleAddr, string calldata query, bytes32 specifier, bytes32[] calldata params) external returns (uint256) {
        uint256 id = dispatch.query(oracleAddr, query, specifier, params);
        return id;
    }

    function helloWorld() public view returns (string memory) {
        return "Hello World";
    }


    // attempts to cancel an existing query
    function cancelQuery(uint256 id) external {
        dispatch.cancelQuery(id);
    }
}
