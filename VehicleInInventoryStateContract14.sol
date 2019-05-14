pragma solidity ^0.4.25;


contract VehicleInInventoryStateContract14 {
    
    address public Dealer;
    uint public Mileage;
    string public Vin;

    
    enum StateType {
        In,
        Out,
        Closed
    }

    StateType public State;

    modifier onlyVehicle( string vin) {
        require(sha256(Vin) == sha256(vin), "Only Vehicle can take action");
        _;
    }
    modifier onlyDealer(address dealer) {
        require(Dealer == dealer, 'Only Dealer can change the state');
        _;
    }
    
    constructor() public {
        State = StateType.In;
    }
    
    function setVin(string vin) public {
        Vin = vin;
    }
    function setDealer( address dealer) {
        Dealer = dealer;
    }

    function vehicleIn(string vin, uint mileage) public onlyVehicle(vin){
        Mileage = mileage;
        State = StateType.In;
    }

    function vehicleOut(string vin, uint mileage) public onlyVehicle(vin){
        Mileage = mileage;
        State = StateType.Out;
    }

    function close(address dealer) public onlyDealer(dealer){
        State = StateType.Closed;
    }
}