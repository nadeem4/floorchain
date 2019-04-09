pragma solidity ^0.4.25;

import './VehicleStateContract7.sol';
import './VehicleInInventoryStateContract7.sol';

contract LenderAgreementContract7 {

    VehicleStateContract7 vehicleStateContract;
    uint public daysToPay;
    uint public geographicalLimitConstraint;
    uint public maxMoney;
    uint public agreementDuration;
    uint public mileageLimit;

    string public location;
    string public name;
    string public description;
    address public lender;

    uint public vehicleAttachedCount = 0;


    enum StateType {
        Initiated,
        Active,
        InvoiceUploaded,
        Closed,
        Renewed
    }
    StateType public State;

    modifier onlyLender(){
        require(lender == msg.sender, "User is not a lender");
        _;
    }
    
    constructor( string _name,  string _description, uint _daysToPay, uint _geographicalLimitConstraint, uint _maxMoney, uint _agreementDuration, uint _mileageLimit ) public {
        lender = msg.sender;
        name = _name;
        description = _description;
        daysToPay = _daysToPay;
        geographicalLimitConstraint = _geographicalLimitConstraint;
        maxMoney = _maxMoney;
        agreementDuration = _agreementDuration;
        mileageLimit = _mileageLimit;

        State = StateType.Initiated;

    }

    function uploadInvoice( string _invoiceNumber, uint _invoiceDate, string _desccription, uint _amount, string _vin, string _oemName, 
        string _dealerNumber, string _groupNumber, string _dealerLocation, address _vehicle ) public {
            require(State != StateType.Closed, 'Agreement is expired, please renew it or create new');
            vehicleStateContract = new VehicleStateContract7();
            vehicleAttachedCount ++ ;
            vehicleStateContract.setInvoiceDetails(_invoiceNumber, _invoiceDate, _desccription, _amount );
            vehicleStateContract.setRoles(lender, msg.sender, _vehicle);
            vehicleStateContract.setDealerInfo(_dealerNumber, _groupNumber, _dealerLocation);
            vehicleStateContract.setVehicleInfo(_vin, _oemName );
            vehicleStateContract.setLenderAgreementDetails(this, geographicalLimitConstraint, mileageLimit);
            
            State = StateType.InvoiceUploaded;
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