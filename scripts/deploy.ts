import { ethers } from "hardhat";

async function main() {
  console.log('Deploying StableCoinToken...');
  const StableCoinToken = await ethers.getContractFactory("StableCoinToken");

  let StableCoinContract = await StableCoinToken.deploy("AUD Stablecoin", "AUDC");

  console.log(
      `The address the Stable Coin Contract WILL have once mined: ${StableCoinContract.address}`
  );

  console.log(
      `The transaction that was sent to the network to deploy the Stable Coin Contract: ${
          StableCoinContract.deployTransaction.hash
      }`
  );

  console.log(
      'The contract is NOT deployed yet; we must wait until it is mined...'
  );
  await StableCoinContract.deployed();
  console.log('StableCoinContract Mined!');

  console.log('Deploying Vault...');
  const Vault = await ethers.getContractFactory("Vault");

  let VaultContract = await Vault.deploy(StableCoinContract.address);

  console.log(
      `The address the Vault Contract WILL have once mined: ${VaultContract.address}`
  );

  console.log(
      `The transaction that was sent to the network to deploy the Vault Contract: ${
          VaultContract.deployTransaction.hash
      }`
  );

  console.log(
      'The contract is NOT deployed yet; we must wait until it is mined...'
  );
  await VaultContract.deployed();
  console.log('VaultContract Mined!');
  let TokenContractOwner = await StableCoinContract.owner();
  console.log(
      `Token Contract Owner: ${TokenContractOwner }`
  );
  console.log('Transfering ownership to Vault...');
  await StableCoinContract.transferOwnership(VaultContract.address);
  TokenContractOwner = await StableCoinContract.owner();
  console.log(
      `Token Contract Owner: ${TokenContractOwner }`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
