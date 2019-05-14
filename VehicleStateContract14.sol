pragma solidity ^0.4.25;

import './VehicleInInventoryStateContract14.sol';

contract VehicleStateContract14 {
    
    VehicleInInventoryStateContract14 vehicleInInventoryStateContract;

    uint public Mileage;
    uint public MileageLimit;
    uint public GeographicalLimitConstraint;
    uint public InvoiceDate;
    uint public Amount;

    address public Lender;
    address public Dealer;
   // address public vehicle;
    
    address public LenderAgreement;

    string public Vin;
    string public InvoiceNumber;
    string public OemName;
    string public Description;
    string public DealerNumber;

    bool public MileageException;
    bool public OffSiteVehicleException;
    bool public ConfirmedSalesException;

    mapping (string=>address) dealerIdentityMapping;

    enum StateType {
        InTransit,
        InInventory,
        CheckInInventory,
        Sold,
        Funded,
        PaidOff,
        PaymentReceived
    }
    enum VehicleType {
        Used,
        New
    }

   // VehicleType public vehicleType = VehicleType.New;

    StateType public State;

    modifier onlyLender() {
        require(Lender == msg.sender, "Only lender can take action");
        _;
    }
    modifier onlyDealer() {
        require( Dealer == msg.sender, "Only dealer can take action");
        _;
    }

    modifier onlyVehicle( string vin) {
        require(sha256(Vin) == sha256(vin), "Only Vehicle can take action");
        _;
    }



    constructor() public {
            State = StateType.InTransit;
    }


    function setRoles( address lender, address dealer) public  {
        Dealer = dealer;
        Lender = lender;
    }

    function setDealerInfo(string dealerNumber) public  {
        DealerNumber = dealerNumber;

    }

    

    function setVehicleInfo( string vin, string oemName) public   {
        Vin = vin;
        OemName = oemName;
    }

    function setLenderAgreementDetails (address lenderAgreement, uint geographicalLimitConstraint, uint mileageLimit) public  {
        LenderAgreement = lenderAgreement;
        GeographicalLimitConstraint = geographicalLimitConstraint;
        MileageLimit = mileageLimit;
    }

    function setInvoiceDetails(string invoiceNumber, uint invoiceDate, string description, uint amount) public {
        InvoiceNumber = invoiceNumber;
        InvoiceDate = invoiceDate;
        Description = description;
        Amount = amount;
    }

    function createInventory() public {
        State = StateType.InInventory;
        vehicleInInventoryStateContract = new VehicleInInventoryStateContract14();
        vehicleInInventoryStateContract.setVin(Vin);
        vehicleInInventoryStateContract.setDealer(Dealer);
    }

    function checkInInventory(uint vehicleDistance, uint mileage, string vin, uint warrentyActivated) public onlyVehicle(vin) {
        if(!MileageException && MileageLimit < mileage) {
            MileageException = true;
        }
        if( warrentyActivated == 0 ) {
            ConfirmedSalesException = false;
        } else {
            ConfirmedSalesException = true;
        }
        if(GeographicalLimitConstraint >= vehicleDistance){
            vehicleInInventoryStateContract.vehicleIn(vin, mileage);
            OffSiteVehicleException = false;
        } else {
            vehicleInInventoryStateContract.vehicleOut(vin, mileage);
            OffSiteVehicleException = true;
        }

        State = StateType.CheckInInventory;
    }

    function sell(VehicleType vehicleType, uint mileage) public onlyDealer{
        Mileage = mileage;
        if(vehicleType == VehicleType.New) { // we are assuming it is in new condition
            require(MileageLimit > mileage, 'Car is in used condition');
            State = StateType.Sold;
        } 
        else { // we are assuming it is in old condition
            require(MileageLimit <= mileage, 'Car is in new condition');
            State = StateType.Sold;
        }
       
    }

    function fund() public onlyDealer{
        State = StateType.Funded;

        vehicleInInventoryStateContract.close(Dealer);

    }

    function payOff() public onlyDealer{
        State = StateType.PaidOff;
    }

    function receivePayment() public onlyLender{
        State = StateType.PaymentReceived;
    }
}