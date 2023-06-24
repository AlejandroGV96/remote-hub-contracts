import { ethers, run, network } from "hardhat";
import {
    ReservationSystemFactory,
    ReservationSystemFactory__factory,
} from "../typechain-types";
import { ReservationSystemTypes } from "../typechain-types/reservation-system-factory.contract.sol/ReservationSystemFactory";

async function main() {
    const ReservationSystemFactory: ReservationSystemFactory__factory =
        await ethers.getContractFactory("ReservationSystemFactory");

    console.log("Deploying ReservationSystemFactory...");
    const reservationSystemFactory: ReservationSystemFactory =
        await ReservationSystemFactory.deploy();
    await reservationSystemFactory.deployed();
    console.log(
        "ReservationSystemFactory deployed to:",
        reservationSystemFactory.address,
    );
    //get the address of the wallet
    const [ethersWallet] = await ethers.getSigners();
    // let res: ReservationSystemTypes.ReservationStruct = {
    //     guestAdress: ethersWallet.address,
    //     price: 1,
    //     roomNumber: 1,
    //     status: 1,
    //     endDate: 1,
    //     startDate: 1,
    // };

    // await reservationSystemFactory.createNewHotel();
    // console.log("Hotel created");

    // await reservationSystemFactory.hfAddReservation(res);
    // console.log("Reservation added");

    // const reservations = await reservationSystemFactory.hfGetAllReservations();
    // console.log(reservations);
    if (network.config.chainId !== 31337 && process.env.ETHERSCAN_API_KEY) {
        await reservationSystemFactory.deployTransaction.wait(5);
        await verify(reservationSystemFactory.address, []);
    }
}

async function verify(contractAddress: string, args: any[]) {
    console.log("Verifying contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
    } catch (error: any) {
        if (error?.message.includes("already verified")) {
            console.log("Contract already verified");
        } else {
            console.log(error);
        }
    }
}

main()
    .then(() => (process.exitCode = 0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });

