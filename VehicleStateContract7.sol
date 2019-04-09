pragma solidity ^0.4.25;

import './VehicleInInventoryStateContract7.sol';

contract VehicleStateContract7 {
    
    VehicleInInventoryStateContract7 vehicleInInventoryStateContract;

    uint public mileage;
    uint public mileageLimit;
    uint public geographicalLimitConstraint;
    uint public invoiceDate;
    uint public amount;

    address public lender;
    address public dealer;
    address public vehicle;
    
    address public lenderAgreement;

    string public vin;
    string public dealerLocation;
    string public invoiceNumber;
    string public oemName;
    string public description;
    string public dealerNumber;
    string public groupNumber;

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

    VehicleType public vehicleType;

    StateType public State;

    modifier onlyLender() {
        require(lender == msg.sender, "Only lender can take action");
        _;
    }
    modifier onlyDealer() {
        require( dealer == msg.sender, "Only dealer can take action");
        _;
    }

    modifier onlyVehicle() {
        require(vehicle == msg.sender, "Only Vehicle can take action");
        _;
    }



    constructor() public {
            State = StateType.InTransit;
    }


    function setRoles( address _lender, address _dealer, address _vehicle) public  {
        dealer = _dealer;
        lender = _lender;
        vehicle = _vehicle;
    }

    function setDealerInfo(string _dealerNumber, string _groupNumber, string _dealerLocation ) public  {
        dealerNumber = _dealerNumber;
        groupNumber = _groupNumber;
        dealerLocation = _dealerLocation;
    }

    function setVehicleInfo( string _vin, string _oemName) public   {
        vin = _vin;
        oemName = _oemName;
    }

    function setLenderAgreementDetails (address _lenderAgreement, uint _geographicalLimitConstraint, uint _mileageLimit) public  {
        lenderAgreement = _lenderAgreement;
        geographicalLimitConstraint = _geographicalLimitConstraint;
        mileageLimit = _mileageLimit;
    }

    function setInvoiceDetails(string _invoiceNumber, uint _invoiceDate, string _description, uint _amount) public {
        invoiceNumber = _invoiceNumber;
        invoiceDate = _invoiceDate;
        description = _description;
        amount = _amount;
    }

    function createInventory() public onlyDealer{
        State = StateType.InInventory;
        vehicleInInventoryStateContract = new VehicleInInventoryStateContract7( dealer, vehicle, vin, '');
    }

    function checkInInventory(uint _vehicleDistance, uint _mileage,  string _dataPackageJson) public onlyVehicle {
        if(geographicalLimitConstraint >= _vehicleDistance){
            vehicleInInventoryStateContract.vehicleIn(vehicle,_mileage, _dataPackageJson);
        } else {
            vehicleInInventoryStateContract.vehicleOut(vehicle, _mileage, _dataPackageJson);
        }
        State = StateType.CheckInInventory;
    }

    function sell(VehicleType _vehicleType, uint _mileage) public onlyDealer{
        mileage = _mileage;
        if(_vehicleType == VehicleType.New) { // we are assuming it is in new condition
            require(mileageLimit > _mileage, 'Car is in used condition');
             State = StateType.Sold;
        } 
        else { // we are assuming it is in old condition
            require(mileageLimit <= _mileage, 'Car is in new condition');
             State = StateType.Sold;
        }
       
    }

    function fund() public onlyDealer{
        State = StateType.Funded;

        vehicleInInventoryStateContract.close(dealer);

    }

    function payOff() public onlyDealer{
        State = StateType.PaidOff;
    }

    function receivePayment() public onlyLender{
        State = StateType.PaymentReceived;
    }
}