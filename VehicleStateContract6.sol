pragma solidity ^0.4.25;

import './VehicleInInventoryStateContract6.sol';

contract VehicleStateContract6 {
    
    VehicleInInventoryStateContract6 vehicleInInventoryStateContract;

    uint public mileage;
    uint public mileageLimit;
    uint public geographicalLimitConstraint;

    address public lender;
    address public dealer;
    address public vehicle;

    string public vin;
    string public dealerLocation;

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



    constructor(uint _geographicalLimitConstraint, uint _mileageLimit, address _lender, address _vehicle, string _vin, string _dealerLocation ) public {
        dealer = msg.sender;
        geographicalLimitConstraint = _geographicalLimitConstraint;
        mileageLimit = _mileageLimit;
        lender = _lender;
        vehicle = _vehicle;
        vin = _vin;
        dealerLocation = _dealerLocation;
        State = StateType.InTransit;
    }


    function createInventory() public onlyDealer{
        State = StateType.InInventory;
        vehicleInInventoryStateContract = new VehicleInInventoryStateContract6( dealer, vehicle, '');
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