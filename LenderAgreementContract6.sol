pragma solidity ^0.4.25;

import './VehicleStateContract6.sol';
import './VehicleInInventoryStateContract6.sol';

contract LenderAgreementContract6 {


    uint public daysToPay;
    uint public geographicalLimitConstraint;
    uint public maxMoney;
    uint public agreementDuration;
    uint public mileageLimit;

    string public location;
    address public lender;

    enum StateType {
        Initiated,
        Active,
        Closed,
        Renewed
    }
    StateType public State;

    modifier onlyLender(){
        require(lender == msg.sender, "User is not a lender");
        _;
    }
    
    constructor( uint _daysToPay, uint _geographicalLimitConstraint, uint _maxMoney, uint _agreementDuration, uint _mileageLimit) public {
        lender = msg.sender;

        daysToPay = _daysToPay;
        geographicalLimitConstraint = _geographicalLimitConstraint;
        maxMoney = _maxMoney;
        agreementDuration = _agreementDuration;
        mileageLimit = _mileageLimit;

        State = StateType.Initiated;

    }

    function active() public onlyLender {
        State = StateType.Active;
    }
    
    function close() public onlyLender{
        State = StateType.Closed;
    }

    function renew( uint _daysToPay, uint _geographicalLimitConstraint, uint _maxMoney, uint _agreementDuration, uint _mileageLimit) public onlyLender{
        lender = msg.sender;
        daysToPay = _daysToPay;
        geographicalLimitConstraint = _geographicalLimitConstraint;
        maxMoney = _maxMoney;
        agreementDuration = _agreementDuration;
        mileageLimit = _mileageLimit;

        State = StateType.Renewed;

    }
}