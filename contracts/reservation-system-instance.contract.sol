// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./reservation-system.types.sol";
import "./PriceConverter.sol";

error NotOwner();
error NotEnoughFunds();

contract ReservationSystemInstance is ReservationSystemTypes {
    using PriceConverter for uint256;

    address public immutable i_InstanceOwner;
    address public immutable i_factoryAddress;
    address private constant DEFAULT_ADDRESS = address(0);
    Reservation[] private HotelReservations;

    event ReservationAdded(Reservation reservation);

    constructor(address _owner) {
        i_InstanceOwner = _owner;
        i_factoryAddress = msg.sender;
    }

    // #region hotel owner

    function addReservation(
        address _sender,
        Reservation calldata _reservation
    ) public onlyFactory onlyInstanceOwner(_sender) returns (bool success) {
        HotelReservations.push(_reservation);
        emit ReservationAdded(_reservation);
        return true;
    }

    function removeReservation(
        address _sender,
        Reservation calldata _reservation
    ) public onlyFactory onlyInstanceOwner(_sender) returns (bool success) {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].guestAddress ==
                _reservation.guestAddress &&
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == _reservation.status
            ) {
                delete HotelReservations[i];
                _burn(i);
                return true;
            }
        }
        return false;
    }

    function removeAllConsolidatedReservations(
        address _sender
    ) public onlyFactory onlyInstanceOwner(_sender) returns (bool success) {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (HotelReservations[i].status == ReservationStatus.CONSOLIDATED) {
                delete HotelReservations[i];
            }
        }
        return true;
    }

    function confirmReservation(
        address _sender,
        Reservation calldata _reservation
    )
        public
        onlyFactory
        onlyReservationOwner(_sender, _reservation)
        returns (bool success)
    {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].guestAddress ==
                _reservation.guestAddress &&
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == _reservation.status &&
                HotelReservations[i].status == ReservationStatus.PENDING
            ) {
                HotelReservations[i].status = ReservationStatus.CONFIRMED;
                return true;
            }
        }
        return false;
    }

    function consolidateReservation(
        address _sender,
        Reservation calldata _reservation
    ) public onlyFactory onlyInstanceOwner(_sender) returns (bool success) {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].guestAddress ==
                _reservation.guestAddress &&
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == _reservation.status &&
                HotelReservations[i].status == ReservationStatus.CONFIRMED
            ) {
                HotelReservations[i].status = ReservationStatus.CONSOLIDATED;
                return true;
            }
        }
        return false;
    }

    function withdraw(
        address payable _sender
    ) public onlyFactory onlyInstanceOwner(_sender) {
        _sender.transfer(address(this).balance);
    }

    // #endregion

    // #region for every user

    function reserveRoom(
        address _sender,
        Reservation calldata _reservation
    )
        public
        payable
        onlyFactory
        enoughForRoomPrice(msg.value, _reservation.price)
        returns (bool)
    {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == ReservationStatus.AVAILABLE
            ) {
                if (HotelReservations[i].guestAddress != DEFAULT_ADDRESS) {
                    payable(HotelReservations[i].guestAddress).transfer(
                        HotelReservations[i].price.usdToWei()
                    );
                }
                HotelReservations[i].guestAddress = _sender;
                HotelReservations[i].status = ReservationStatus.PENDING;
                payable(_sender).transfer(
                    msg.value - _reservation.price.usdToWei()
                );
                return true;
            }
        }
        revert("No room available");
    }

    function reclaimRoom(
        address _sender,
        Reservation calldata _reservation
    )
        public
        onlyFactory
        onlyReservationOwner(_sender, _reservation)
        returns (bool success)
    {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].guestAddress ==
                _reservation.guestAddress &&
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == _reservation.status &&
                HotelReservations[i].status == ReservationStatus.AVAILABLE
            ) {
                HotelReservations[i].status = ReservationStatus.PENDING;
                return true;
            }
        }
        return false;
    }

    function makeReservationAvailable(
        address _sender,
        Reservation calldata _reservation
    )
        public
        onlyFactory
        onlyReservationOwner(_sender, _reservation)
        returns (bool success)
    {
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (
                HotelReservations[i].guestAddress ==
                _reservation.guestAddress &&
                HotelReservations[i].price == _reservation.price &&
                HotelReservations[i].startDate == _reservation.startDate &&
                HotelReservations[i].endDate == _reservation.endDate &&
                HotelReservations[i].roomNumber == _reservation.roomNumber &&
                HotelReservations[i].status == _reservation.status &&
                HotelReservations[i].status == ReservationStatus.PENDING
            ) {
                HotelReservations[i].status = ReservationStatus.AVAILABLE;
                return true;
            }
        }
        return false;
    }

    function getAllReservations()
        public
        view
        onlyFactory
        returns (Reservation[] memory)
    {
        // get only the ones that are available
        Reservation[] memory availableReservations = new Reservation[](
            HotelReservations.length
        );
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            availableReservations[i] = HotelReservations[i];
        }
        return availableReservations;
    }

    function getMyReservations(
        address _sender
    ) public view onlyFactory returns (Reservation[] memory) {
        Reservation[] memory myReservations = new Reservation[](
            HotelReservations.length
        );
        for (uint256 i = 0; i < HotelReservations.length; i++) {
            if (HotelReservations[i].guestAddress == _sender) {
                myReservations[i] = HotelReservations[i];
            }
        }
        return myReservations;
    }

    // #endregion

    function _burn(uint index) internal {
        require(index < HotelReservations.length);
        HotelReservations[index] = HotelReservations[
            HotelReservations.length - 1
        ];
        HotelReservations.pop();
    }

    function getBalance(
        address _sender
    ) public view onlyFactory onlyInstanceOwner(_sender) returns (uint256) {
        return address(this).balance;
    }

    // #region Modifiers

    modifier enoughForRoomPrice(uint256 _value, uint256 _roomPrice) {
        if (_roomPrice > _value.weiToUsd()) {
            revert NotEnoughFunds();
        }
        _;
    }
    modifier onlyFactory() {
        if (msg.sender != i_factoryAddress) {
            revert NotOwner();
        }
        _;
    }

    modifier onlyInstanceOwner(address _msgSender) {
        if (_msgSender != i_InstanceOwner) {
            revert NotOwner();
        }
        _;
    }

    modifier onlyReservationOwner(
        address _msgSender,
        Reservation calldata _reservation
    ) {
        if (_msgSender != _reservation.guestAddress) {
            revert NotOwner();
        }
        _;
    }

    // #endregion
}
