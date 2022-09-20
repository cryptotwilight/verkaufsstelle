// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-product/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenProduct.sol"; 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "./IVerkaufsstelle.sol";
/**
 * This is teh Verkaufsstelle implementation 
 */
contract Verkaufsstelle is IVerkaufsstelle {

    address NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address self; 
    address administrator;

    uint256 [] allPayments; 
    mapping(address=>uint256[]) paymentIdsByAddress; 
    mapping(uint256=>Payment) paymentsById; 

    mapping(address=>mapping(address=>bool)) hasPaynentByProductByBuyer; 

    constructor(address _admin) {
        administrator = _admin; 
        self = address(this);
    }

    function getPayments() view external returns (Payment [] memory _payments){
        uint256 [] memory  paymentIds_ = paymentIdsByAddress[msg.sender];
        return getPayments(paymentIds_);
    }

    function payForProduct(address _openProductAddress, uint256 _quantity) payable external returns (bool _paid){
        IOpenProduct product_ = IOpenProduct(_openProductAddress);
        address erc20Address_ = product_.getErc20(); 
        uint256 paidValue_ = 0; 
        if(erc20Address_ == NATIVE) {
            require(msg.value >= product_.getPrice(), "insufficient payment transmitted");
            paidValue_ = msg.value; 
        }
        else {
           IERC20 erc20_ = IERC20(product_.getErc20()); 
           erc20_.transferFrom(msg.sender, self, product_.getPrice());
           paidValue_ = product_.getPrice(); 
        }

        Payment memory payment_ = Payment({
                                            id : block.timestamp,
                                            product : _openProductAddress,   
                                            buyer : msg.sender, 
                                            seller : product_.getFeatureADDRESSValue("OWNER"),
                                            quantity :  _quantity, 
                                            paymentDate : block.timestamp, 
                                            paidValue : paidValue_
                                        });
        paymentsById[payment_.id] = payment_;
        paymentIdsByAddress[msg.sender].push(payment_.id);
        allPayments.push(payment_.id);
        hasPaynentByProductByBuyer[msg.sender][_openProductAddress] = true; 
        return true; 
    }

    function isPaid(address _product, address _buyer) view external returns (bool paid) { 
        return hasPaynentByProductByBuyer[_buyer][_product];
    }


    function getAllPayments() view external returns (Payment [] memory _payments) {
        return getPayments(allPayments);
    }


    function setAdministrator(address _newAdmin) external returns (bool _set) {
        require(msg.sender == administrator, "admin only");
        administrator = _newAdmin; 
        return true; 
    }

    function withdraw(address _erc20)  external returns (bool _complete) {
        require(msg.sender == administrator, "admin only");
         if(_erc20 == NATIVE) {
            address payable destination = payable(msg.sender); 
            destination.transfer(self.balance);
        }
        else {
           IERC20 erc20_ = IERC20(_erc20); 
           erc20_.transfer(msg.sender, erc20_.balanceOf(self));
        }

        return true; 
    }


//============================ INTERNAL ==================================================

   function getPayments(uint256 [] memory  _ids) view internal returns (Payment[] memory _payments) {
       _payments = new Payment[](_ids.length);
       for(uint256 x = 0; x < _ids.length; x++) {
           _payments[x] = paymentsById[_ids[x]];
       }
       return _payments; 
   }

}