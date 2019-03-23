pragma solidity ^0.4.25;


contract VehicleInInventoryStateContract6 {
    
    address public vehicle;
    address public dealer;
    uint public mileage;
    string public dataPackageJson;

    
    enum StateType {
        In,
        Out,
        Closed
    }

    StateType public State;

    modifier onlyVehicle(address _vehicle ) {
        require(vehicle == _vehicle, 'Only Vehicle can change the state');
        _;
    }
    modifier onlyDealer(address _dealer) {
        require(dealer == _dealer, 'Only Dealer can change the state');
        _;
    }
    
    constructor(address _dealer, address _vehicle, string _dataPackageJson) public {
        dealer = _dealer;
        dataPackageJson = _dataPackageJson;
        vehicle = _vehicle;
        State = StateType.In;
    }

    function vehicleIn(address _vehicle, uint _mileage, string _dataPackageJson) public onlyVehicle(_vehicle){
        dataPackageJson = _dataPackageJson;
        mileage = _mileage;
        State = StateType.In;
    }

    function vehicleOut(address _vehicle, uint _mileage,  string _dataPackageJson) public onlyVehicle(_vehicle){

        dataPackageJson = _dataPackageJson;
        mileage = _mileage;
        State = StateType.Out;
    }

    function close(address _dealer) public onlyDealer(_dealer){
        State = StateType.Closed;
    }
}