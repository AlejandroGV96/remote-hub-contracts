const ethers = require("ethers");
const fs = require("fs");
require("dotenv").config();

async function main() {
    const wallet = new ethers.Wallet(process.env.WALLET_PRIVATE_KEY);
    const encryptedWallet = await wallet.encrypt(process.env.WALLET_PASSWORD);
    fs.writeFileSync(".encryptedWallet.json", encryptedWallet);
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
