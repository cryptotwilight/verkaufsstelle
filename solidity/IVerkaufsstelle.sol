// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
/**
 * This is the Verkaufsstelle interface 
 */
interface IVerkaufsstelle { 


    struct Payment { 
        uint256 id; 
        address product; 
        address buyer; 
        address seller;
        uint256 quantity; 
        uint256 paymentDate; 
        uint256 paidValue; 
    }

    function getPayments() view external returns (Payment [] memory _payments);

    function payForProduct(address _openProduct, uint256 _quantity) payable external returns (bool _paid);

    function isPaid(address _product, address _buyer) view external returns (bool paid);
}