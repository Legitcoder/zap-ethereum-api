import "./EthAdapter.sol";
import "./TokenAdapter.sol";

//send eth to obtain market token
//use market token to bond to gated markets
//child contracts can control gate unbonding 

contract EthGatedMarket is EthAdapter{

    bool public bondAllow;
    bool public unbondAllow;
    bytes32 public gatewaySpecifier;

    FactoryTokenInterface reserveToken;//zap
    FactoryTokenInterface gatewayToken;//token used to bond in gated markets
    TokenAdapter marketFactory;//factory for gated curves  

    constructor(address coordinator, address tokenFactory)
    EthAdapter(coordinator, tokenFactory, 1) {

        bondAllow = false;
        unbondAllow = false;
    }

    ///initiallize gateway eth->gateway token curve, set exchange rate of eth/reserve token 
    function initializeGateway( 
        bytes32 title, 
        uint256 pubKey,
        bytes32 specifier, 
        bytes32 symbol, 
        int256[] curve,
        uint256 adapterRate
        ) onlyOwner {

        gatewayToken = FactoryTokenInterface(
            initializeCurve(
                pubKey, title, specifier, symbol, curve
            )
        );

        gatewaySpecifier = specifier;
        setAdapterRate(adapterRate); 
        marketFactory = new TokenAdapter(coord, tokenFactory, gatewayToken);
        bondAllow = true; 
    } 

    ///bond to obtain gateway tokens in exchange for eth, able to bond to gated curves
    function gatewayBond(uint quantity) public payable {
        
        require(bondAllow, "bond not allowed");
        super.bond(address(this), gatewaySpecifier, quantity);
    }  

    ///unbond to obtain eth in exchange for gateway tokens
    function gatewayUnbond(uint quantity) public {

        require(unbondAllow, "unbond not allowed");
        super.unbond(address(this), gatewaySpecifier, quantity);
    }

    ///initialize a new gated market
    function initializeMarketCurve(
        uint256 pubKey,
        bytes32 title, 
        bytes32 specifier, 
        bytes32 symbol, 
        int256[] curve
    ) public {
        marketFactory.initializeCurve(    
            pubKey, title, specifier, symbol, curve
        );
    }
    
    ///bond to gated market with gateway token
    //TODO: users can not get gateway tokens, because gateway token owner is this contract
    function marketBond(bytes32 specifier, uint quantity) {
        
        marketFactory.ownerBond(address(this), specifier, quantity); 
    }

    ///unbond from gated market with gateway token
    //TODO: users can not get gateway tokens, because gateway token owner is this contract
    function marketUnbond(bytes32 specifier, uint quantity) {

        marketFactory.ownerUnbond(address(this), specifier, quantity);
    }

    ///allow bond
    function allowBond() onlyOwner {  
        bondAllow = true; 
    }

    ///disallow bond
    function disallowBond() onlyOwner {  
        bondAllow = false;
    }

    ///allow unbond
    function allowUnbond() onlyOwner {  
        unbondAllow = true; 
    }

    ///disallow unbond
    function disallowUnbond() onlyOwner {  
        unbondAllow = false;
    }
}
