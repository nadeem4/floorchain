pragma solidity ^0.4.25;

import './VehicleStateContract8.sol';
import './VehicleInInventoryStateContract8.sol';

contract LenderAgreementContract8 {

    VehicleStateContract8 vehicleStateContract;
    uint public DaysToPay;
    uint public GeographicalLimitConstraint;
    uint public MaxMoney;
    uint public AgreementDuration;
    uint public MileageLimit;

    string public Location;
    string public Name;
    string public Description;
    address public Lender;

    uint public VehicleAttachedCount = 0;


    enum StateType {
        Initiated,
        Active,
        InvoiceUploaded,
        Closed,
        Renewed
    }
    StateType public State;

    modifier onlyLender(){
        require(Lender == msg.sender, "User is not a lender");
        _;
    }
    
    constructor( string name,  string description, uint daysToPay, uint geographicalLimitConstraint, uint maxMoney, uint agreementDuration, uint mileageLimit ) public {
        Lender = msg.sender;
        Name = name;
        Description = description;
        DaysToPay = daysToPay;
        GeographicalLimitConstraint = geographicalLimitConstraint;
        MaxMoney = maxMoney;
        AgreementDuration = agreementDuration;
        MileageLimit = mileageLimit;

        State = StateType.Initiated;

    }

    function uploadInvoice( string invoiceNumber, uint invoiceDate, string desccription, uint amount, string vin, string oemName,  string dealerNumber, address dealer ) 
        public onlyLender{
            require(State != StateType.Closed, 'Agreement is expired, please renew it or create new');
            vehicleStateContract = new VehicleStateContract8();
            VehicleAttachedCount ++ ;
            vehicleStateContract.setInvoiceDetails(invoiceNumber, invoiceDate, desccription, amount );
            vehicleStateContract.setRoles(Lender, dealer);
            vehicleStateContract.setDealerInfo(dealerNumber);
            vehicleStateContract.setVehicleInfo(vin, oemName );
            vehicleStateContract.setLenderAgreementDetails(this, GeographicalLimitConstraint, MileageLimit);
            
            State = StateType.InvoiceUploaded;
    }

    function active() public onlyLender {
        State = StateType.Active;
    }
    
    function close() public onlyLender{
        State = StateType.Closed;
    }

    function renew( uint daysToPay, uint geographicalLimitConstraint, uint maxMoney, uint agreementDuration, uint mileageLimit) public onlyLender{
        Lender = msg.sender;
        DaysToPay = daysToPay;
        GeographicalLimitConstraint = geographicalLimitConstraint;
        MaxMoney = maxMoney;
        AgreementDuration = agreementDuration;
        MileageLimit = mileageLimit;

        State = StateType.Renewed;

    }

    
}