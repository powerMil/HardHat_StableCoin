// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";
import {FixedPoint,fromFraction, mulFixedPoint, divFixedPoint} frp, "./FixedPoint.sol";

contract StableCoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 pulbic feeRatePercentage;
    uint256 public initialCollateralRationPercentage;
    uint256 public depositorCoinLockTime;

    error InitialCollateralRatioError (string message, uint256 minumDepositAmount);

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRationPercentage,
        uint256 _depositorCoinLockTime
     
    ) ERC20(_name, _symbol, 18) {

        oracle=_oracle;
        feeRatePercentage=_feeRatePercentage;
        initialCollateralRationPercentage=_initialCollateralRationPercentage;
        depositorCoinLockTime=_depositorCoinLockTime;
    }

    function mint() external payable {

        uint256 fee =  _getFee(msg.value);
      
        uint256 mintStableCoinAmount=(msg.value -fee)*oracle.getPrice();
        _mint (msg.sender, mintStableCoinAmount);
    }

    function burn(uint256 burnStablecoinAmount) external {

        _burn(msg.sender,burnStablecoinAmount);

          uint256 refundingEth =burnStablecoinAmount / oracle.getPrice();
          uint256 fee = _getFee(refundingEth);

        (bool success,)msg.sender.call {value:(refundingEth-fee)}("");
        require(success,"STC: Burn refund transaction failed");
    }


    function _getFee (uint256 ethAmount) private view returns(uint256){
        return (ethAmount * feeRatePercentage) / 100;
    }

        function depositCollateralBuffer () external payable {
            int256 deficitOrSurplusInUsd=_getDeficitOrSurplusInContractInUSD ();
           
            

            if (deficitOrSurplusInUsd <= 0){ // in case is a new contract
                uint256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1); //convert to positive and then transform to uint256 
                uint256 deficitInEth = deficitInUsd / orcale.getPrice();
               
                uint256 addedSurplusEth = msg.value - deficitInEth; 
            uint256 requiredInitialSurplusInUsd = intialCollateralRatioPercentage  * totalSupply /100;
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / oracle.getPrice();


            if (addedSurplusEth < requiredInitialSurplusInEth) {
                uint256 minimumDeposit= eficitInEth + requiredInitialSurplusInEth;
                revert InitialCollateralRatioError ("STC: Initial collateral ratio not met, minimum is ", minimumDeposit );
  

            }

       
             uint256 initialDepositorSupply = addedSurplusEth * oracle.getPrice();
                depositorCoin = new DepositorCoin("Depositor Coin", "DPC", depositorCoinLockTime, msg.sender, initialDepositorSupply );
                //new surplus: (msg.value - deficitInEth)* oracle.getPrice();

            return;
            } 
            
             uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
              FixedPoint usdInDpcPrice=fromFraction(depositorCoin.totalSupply(), surplusInUsd);
            uint256 mintDepositorCoinAmount = mulFixedPoint( msg.value * oracle.getPrice(), usdInDpcPrice) ;
            depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
            

        }

        function withdrawCollateralBuffer(uint256 burnDepositorCoinAmount) external {
              
        int256 deficitOrSurplusInUsd=_getDeficitOrSurplusInContractInUSD ();
        require (deficitOrSurplusInUsd > 0, "STC: No depositor funds to withdraw");

                  uint256 surplusInUsd=uint256(deficitOrSurplusInUsd);
            depositorCoin.burn(msg.sender,burnDepositorCoinAmount);


                 FixedPoint usdInDpcPrice=fromFraction(depositorCoin.totalSupply(), surplusInUsd);

            uint256 refundingUsd = divFixedPoint(burnDepositorCoinAmount, usdInDpcPrice);

            uint256 refundingEth = refundingUsd /oracle.getPrice();;

             (bool success,)msg.sender.call {value:refundingEth}("");
        require(success,"STC: Withdraw collateral buffer transaction failed");

        }

     function _getDeficitOrSurplusInContractInUSD () private view returns (int256){

           
         
         uint256 ethContractBalanceInUsd= (address(this).balance - msg.value) * oracle.getPrice();;
         uint256 totalStableCoinBalanceInUsd= totalSupply;

        int256 surplusOrDeficit= int256(ethContractBalanceInUsd) - int256(totalStableCoinBalanceInUsd);
        return surplusOrDeficit;


     }
    
}
