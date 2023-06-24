// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./reservation-system-instance.contract.sol";

error AlreadyExists();

contract ReservationSystemFactory is ReservationSystemTypes {
    using PriceConverter for uint256;

    mapping(address => ReservationSystemInstance) private addressToInstance;
    mapping(address => bool) private addressToBool;

    address private constant DEFAULT_ADDRESS = address(0);

    event ReservationAdded(Reservation reservation);
    event BalanceChanged(bool success);
    event ReservationsChanged(bool success);

    // #region: for hotel owner
    function hfWithdrawFunds() public senderHasInstance returns (bool success) {
        addressToInstance[msg.sender].withdraw(payable(msg.sender));
        emit BalanceChanged(true);
        return true;
    }

    function hfAddReservation(
        Reservation memory _reservation
    ) public senderHasInstance returns (bool success) {
        Reservation memory reservation = Reservation(
            address(0),
            _reservation.price,
            _reservation.startDate,
            _reservation.endDate,
            _reservation.roomNumber,
            ReservationStatus.AVAILABLE
        );
        addressToInstance[msg.sender].addReservation(msg.sender, reservation);
        emit ReservationsChanged(true);
        return true;
    }

    function hfConsolidateReservation(
        Reservation memory _reservation
    ) public senderHasInstance returns (bool success) {
        addressToInstance[msg.sender].consolidateReservation(
            msg.sender,
            _reservation
        );
        emit ReservationsChanged(true);
        return true;
    }

    function hfRemoveConsolidatedReservations(
        address _hotelAddress
    ) public senderHasInstance returns (bool success) {
        addressToInstance[_hotelAddress].removeAllConsolidatedReservations(
            msg.sender
        );
        emit ReservationsChanged(true);
        return true;
    }

    function hfRemoveReservation(
        Reservation memory _reservation
    ) public senderHasInstance returns (bool success) {
        addressToInstance[msg.sender].removeReservation(
            msg.sender,
            _reservation
        );
        emit ReservationsChanged(true);
        return true;
    }

    // #endregion

    // #region: for every user
    function createNewHotel() public alreadyExists returns (address) {
        addressToInstance[msg.sender] = new ReservationSystemInstance(
            msg.sender
        );
        addressToBool[msg.sender] = true;
        return addressToInstance[msg.sender].i_InstanceOwner();
    }

    function hotelExists(address _hotelAddress) public view returns (bool) {
        return addressToBool[_hotelAddress];
    }

    function hfGetAllReservations(
        address _hotelAddress
    ) public view returns (Reservation[] memory) {
        return addressToInstance[_hotelAddress].getAllReservations();
    }

    function hfGetMyReservations(
        address _hotelAddress
    ) public view returns (Reservation[] memory) {
        return addressToInstance[_hotelAddress].getMyReservations(msg.sender);
    }

    function hfReserveRoom(
        address _hotelAddress,
        Reservation memory _reservation
    ) public payable returns (bool success) {
        addressToInstance[_hotelAddress].reserveRoom{ value: msg.value }(
            msg.sender,
            _reservation
        );
        emit ReservationsChanged(true);
        emit BalanceChanged(true);
        return true;
    }

    function hfReclaimRoom(
        address _hotelAddress,
        Reservation memory _reservation
    ) public returns (bool success) {
        addressToInstance[_hotelAddress].reclaimRoom(msg.sender, _reservation);
        emit ReservationsChanged(true);
        return true;
    }

    function hfMakeReservationAvailable(
        address _hotelAddress,
        Reservation memory _reservation
    ) public returns (bool success) {
        addressToInstance[_hotelAddress].makeReservationAvailable(
            msg.sender,
            _reservation
        );
        emit ReservationsChanged(true);
        return true;
    }

    function hfConfirmReservation(
        address _hotelAddress,
        Reservation memory _reservation
    ) public returns (bool success) {
        addressToInstance[_hotelAddress].confirmReservation(
            msg.sender,
            _reservation
        );
        emit ReservationsChanged(true);
        return true;
    }

    // #endregion

    // #region: helpers
    function getReservationPrice(uint256 _price) public view returns (uint256) {
        return _price.usdToWei();
    }

    function hfGetBalance(address _hotelAddress) public view returns (uint256) {
        return addressToInstance[_hotelAddress].getBalance(msg.sender);
    }

    // #endregion

    // #region: modifiers
    modifier alreadyExists() {
        if (
            addressToInstance[msg.sender] !=
            ReservationSystemInstance(DEFAULT_ADDRESS)
        ) {
            revert AlreadyExists();
        }
        _;
    }

    modifier senderHasInstance() {
        if (
            addressToInstance[msg.sender] ==
            ReservationSystemInstance(DEFAULT_ADDRESS)
        ) {
            revert NotOwner();
        }
        _;
    }
    // #endregion
}
