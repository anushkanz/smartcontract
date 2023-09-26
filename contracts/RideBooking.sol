pragma solidity ^0.8.0;

contract RideBooking {
    struct Ride {
        string from;
        string name;
        uint256 date;
        string start;
        string dropoff;
        uint256 price;
        uint256 people;
    }
    address public owner;

    Ride[] public rides;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function bookRide(
        string memory _from,
        string memory _name,
        uint256 _date,
        string memory _start,
        string memory _dropoff,
        uint256 _price,
        uint256 _people
    ) public {
        Ride memory newRide = Ride(
            _from,
            _name,
            _date,
            _start,
            _dropoff,
            _price,
            _people
        );
        rides.push(newRide);
    }

    function getBookings(uint256 index) public view returns (Ride memory) {
        require(index < rides.length, "Invalid index");
        return rides[index];
    }

    function getAllBookings() public view returns (Ride[] memory) {
        return rides;
    }

    function updateBooking(
        uint256 index,
        string memory _from,
        string memory _name,
        uint256 _date,
        string memory _start,
        string memory _dropoff,
        uint256 _price,
        uint256 _people
    ) public onlyOwner {
        require(index < rides.length, "Invalid index");

        Ride storage ride = rides[index];
        ride.from = _from;
        ride.name = _name;
        ride.date = _date;
        ride.start = _start;
        ride.dropoff = _dropoff;
        ride.price = _price;
        ride.people = _people;
    }

    function deleteBooking(uint256 index) public onlyOwner {
        require(index < rides.length, "Invalid index");

        for (uint256 i = index; i < rides.length - 1; i++) {
            rides[i] = rides[i + 1];
        }
        rides.pop();
    }
}
