// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract ReservationSystemTypes {
    struct Reservation {
        address guestAddress;
        uint256 price;
        uint startDate;
        uint endDate;
        uint roomNumber;
        ReservationStatus status;
    }

    enum ReservationStatus {
        AVAILABLE,
        PENDING,
        CONFIRMED,
        CONSOLIDATED
    }
}
