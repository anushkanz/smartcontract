// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarBookingContract {
    address public owner;
    uint256 public bookingCount = 0;
    uint256 public driverCount = 0;

    struct Booking {
        uint256 id;
        string name;
        address user;
        address driver;
        uint256 fare;
        string pickup;
        string dropoff;
        uint256 date;
        uint256 people;
        bool isCompleted;
        bool isPaid;
        bool isPickup;
    }

    struct Driver {
        address driverAddress;
        bool isAvailable;
    }

    Booking[] public bookings;
    mapping(address => Driver) public drivers;
    address[] public driversList;

    event BookingCreated(
        uint256 id,
        string name,
        address indexed user,
        uint256 fare,
        string pickup,
        string dropoff,
        uint256 date,
        uint256 people
    );
    event BookingAccepted(uint256 id, address indexed driver);
    event BookingCompleted(uint256 id);
    event BookingPaid(uint256 id, address indexed driver);
    event BookingPickup(uint256 id, address indexed driver);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createBooking(
        string memory _name,
        uint256 _fare,
        string memory _pickup,
        string memory _dropoff,
        uint256 _date,
        uint256 _people
    ) external returns (uint256) {
        bookingCount++;
        bookings.push(
            Booking(
                bookingCount,
                _name,
                msg.sender,
                address(0),
                _fare,
                _pickup,
                _dropoff,
                _date,
                _people,
                false,
                false,
                false
            )
        );
        emit BookingCreated(
            bookingCount,
            _name,
            msg.sender,
            _fare,
            _pickup,
            _dropoff,
            _date,
            _people
        );
        return bookingCount;
    }

    function acceptBooking(uint256 _id) external {
        require(
            drivers[msg.sender].isAvailable == true,
            "Only available drivers can accept bookings"
        );
        require(
            bookings[_id].driver == address(0),
            "Booking is already accepted by a driver"
        );
        bookings[_id].driver = msg.sender;
        emit BookingAccepted(_id, msg.sender);
    }

    function completeBooking(uint256 _id) external {
        require(
            bookings[_id].driver == msg.sender,
            "Only the assigned driver can complete the booking"
        );
        require(
            bookings[_id].isPickup == true,
            "Before complete, the driver needs to mark pickup as completed"
        );
        require(!bookings[_id].isCompleted, "Booking is already completed");
        bookings[_id].isCompleted = true;
        emit BookingCompleted(_id);
    }

    function markPickupCompleted(uint256 _id) external {
        require(
            bookings[_id].driver == msg.sender,
            "Only the assigned driver can mark pickup as completed"
        );
        require(
            !bookings[_id].isPickup,
            "Pickup is already marked as completed"
        );
        bookings[_id].isPickup = true;
        emit BookingPickup(_id, msg.sender);
    }

    function payDriver(uint256 _id) external {
        require(
            bookings[_id].user == msg.sender,
            "Only the booking user can initiate payment"
        );
        require(
            bookings[_id].isCompleted,
            "Booking must be completed to initiate payment"
        );
        require(
            !bookings[_id].isPaid,
            "Payment has already been made for this booking"
        );
        payable(bookings[_id].driver).transfer(bookings[_id].fare);
        bookings[_id].isPaid = true;
        emit BookingPaid(_id, bookings[_id].driver);
    }

    function addDriver() external {
        require(
            drivers[msg.sender].driverAddress == address(0),
            "Driver already registered"
        );
        driverCount++;
        drivers[msg.sender] = Driver(msg.sender, true);
        driversList.push(msg.sender); // Add the driver's address to the list
    }

    function setDriverAvailability(bool _isAvailable) external {
        drivers[msg.sender].isAvailable = _isAvailable;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getBookings() public view returns (Booking[] memory) {
        return bookings;
    }

    function getRegisteredDriversList() public view returns (address[] memory) {
        return driversList;
    }

    receive() external payable {}
}
