# Testchain #
The purpose of this project is to setup a local testchain for testing Ajna deployment and integration testing.

## Prerequisites ##
You'll need `docker` and `docker-compose` installed.

## Setup ##

### Create a docker image with a local testnet ###
This creates a single instance of `ganache` and uses a wallet seed for consistant account generation.

```
docker-compose up
```

Here are the accounts and private keys available for seed 20070213:
```
Available Accounts
==================
(0) 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E (1000 ETH)
(1) 0xD293C11Cd5025cd7B2218e74fd8D142A19833f74 (1000 ETH)
(2) 0xb240043d57f11a0253743566C413bB8B068cb1F2 (1000 ETH)
(3) 0x6f386a7a0EF33b7927bBF86bf06414884a3FDFE5 (1000 ETH)
(4) 0x122230509E5bEEd0ea3c20f50CC87e0CdB9d7e1b (1000 ETH)
(5) 0xB932C1F1C422D39310d0cb6bE57be36D356fc0c8 (1000 ETH)
(6) 0x9A7212047c046a28E699fd8737F2b0eF0F94B422 (1000 ETH)
(7) 0x7CA0e91795AD447De38E4ab03b8f1A829F38cA58 (1000 ETH)
(8) 0xd21BB9dEF715C0E7A1b7F18496F2475bcDeFA1Be (1000 ETH)
(9) 0xef62E4A54bE04918f435b7dF83c01138521C009b (1000 ETH)
(10) 0xAecE01e5Ba6B171455B97FBA91b33E1b138AF60c (1000 ETH)
(11) 0x9D3904CD72d3BDb97C3B2e266A60aBe127B6F940 (1000 ETH)
(12) 0x2636aD85Da87Ff3780e1eC5e48fC0aBa33849B16 (1000 ETH)
(13) 0x81fFF6A381bF1aC11ed388124186C177Eb8623f4 (1000 ETH)
(14) 0x8596d963e0DEBCa873A56FbDd2C9d119Aa0eB443 (1000 ETH)
(15) 0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA (1000 ETH)

Private Keys
==================
(0) 0x2bbf23876aee0b3acd1502986da13a0f714c143fcc8ede8e2821782d75033ad1
(1) 0x997f91a295440dc31eca817270e5de1817cf32fa99adc0890dc71f8667574391
(2) 0xf456f1fa8e9e7ec4d24f47c0470b7bb6d8807ac5a3a7a1c5e04ef89a25aa4f51
(3) 0x6b7f753700a3fa90224871877bfb3d6bbd23bd7cc25d49430ce7020f5e39d463
(4) 0xaf12577dbd6c3f4837fe2ad515009f9f71b03ce8ba4a59c78c24fb5f445b6d01
(5) 0x8b4c4ea4246dd9c3404eda8ec30145dbe9c23744876e50b31dc8e9a0d26f0c25
(6) 0x061d84e8c34b8505b1cefae91de5204c680ed9b241da051a2d8bdcad4393c24b
(7) 0xe15dec57b7eb7bb736b6e9d8501010ca5973ee3027b6ecb567f76fa89a6e9716
(8) 0xe5fe199c1ac195ee83fa28dd7bbb12c6bed2ebe6a1f76e55b0b318373c42059d
(9) 0xdb95f6b72665d069dd2776d1c747d1ab2ee9184b26da57e3f4708acc5595aa79
(10) 0x2739db52256c7aa7aabab565d312bbd41c011fe8840b814ba6897929d274abed
(11) 0x1d612f43a142a29d0efb31b51b16d49c68d3b0efff47d39088d38a6ee402204a
(12) 0xc748c58b01eb90e347f869b9dab9ec78613d6cd87e334204424727a363295cab
(13) 0xfd4ea1b995ed10c8614c1f43cbd478dff72e8cc64b715131ec4fbba795e08fff
(14) 0x447bca6c40103b20b6a63bc967f379819cd8f82436ecb54704b3fd8011e74d00
(15) 0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8
```

Let's `export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA` to use the last account for deployment.

With the testchain up, run the following command to check your ETH balance:
```
curl 0.0.0.0:8555 -X POST -H "Content-Type: application/json" --data '{
    "jsonrpc": "2.0", "id":1, 
    "method": "eth_getBalance",
    "params": [
        "'${DEPLOY_ADDRESS}'",
        "latest"
    ]
}'
```

You should receive the following response, indicating the account has 1000 ETH, and, more importantly, that you can send JSON-RPC requests to the container.
```
{"jsonrpc":"2.0","id":4,"result":"0x3635c9adc5dea00000"}
```
If you already deployed Ajna to the endpoint, it should return a slightly smaller number.

### Deploy Ajna to the testnet ###

```
./deploy-ajna.sh
```

Record addresses printed by the deployment script here:
```
=== Local Testchain Addresses ===
AJNA token      0x25Af17eF4E2E6A4A2CE586C9D25dF87FD84D4a7d
GrantFund       0xda146447b60abFaC7E4e0A0f4064eA6FF6dc7BCA
ERC20 factory   0xaCBDae8801983605EFC40f48812f7efF797504da
ERC721 factory  0xC01c2D208ebaA1678F14818Db7A698F11cd0B6AB
PoolInfoUtils   0x325Cf36179A4d55F09bE9d3C2E1f4337d49A9f2b
PositionManager 0x12865F86F31e674738192cd3AE154485A6FCB2b6
RewardsManager  0x06F4dC71a0029E31141fa23988735950324A48C7
TokensFactory   0x4f05DA51eAAB00e5812c54e370fB95D4C9c51F21
```

### Create some test tokens ###

Unfortunately, mainnet tokens cannot be tested on the fork.  Instead, use the Tokens Factory to create some new ones.  `create-token.sh` was made to facilitate this.  To use it, first `export TOKENSFACTORY=<address from above>`, and then pass it the following parameters:
 * Token name
 * Token symbol
 * Number of decimals (18 is standard)
 * Address to which tokens shall be minted
 * Amount of tokens to mint (in denormalized token precision)

Here's an example:
```
export TOKENSFACTORY=0x4f05DA51eAAB00e5812c54e370fB95D4C9c51F21
./create-token.sh TestWrappedETH TWETH 18 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E 1000ether
./create-token.sh TestDai TDAI 18 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E 500000ether
```

Record the output here:
```
Deployed TWETH to 0x97112a824376a2672a61c63c1c20cb4ee5855bc7 and minted 1000ether to 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E.
Deployed TDAI to 0xc91261159593173b5d82e1024c3e3529e945dc28 and minted 500000ether to 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E.
```

Validate you can interact with these tokens by checking their number of decimal places:
```
cast call 0x97112a824376a2672a61c63c1c20cb4ee5855bc7 "decimals()(uint8)"
18
cast call 0xc91261159593173b5d82e1024c3e3529e945dc28 "decimals()(uint8)"
18
```

### Persist changes ###

Update any dependent repositories (such as _sdk_) with the new addresses.

~~Run `docker commit ajna-testnet ajna/testnet` to save the `ajna-testnet` container as an image named `ajna/testnet`.~~
Until we make the repo public, Ed will run the following to persist the image:
```
docker commit ajna-testnet noepel/ajna-testnet:<tag>
docker push noepel/ajna-testnet:<tag>
```

Check and record the block height, that you may later confirm whether you're working with a fresh deployment:
```
curl 0.0.0.0:8555 -X POST -H "Content-Type: application/json" --data '{
    "jsonrpc": "2.0", "id":2,
    "method": "eth_blockNumber",
    "params":[]
}'
```
You should receive the following response, indicating the block height is 16295021:
```
{"id":2,"jsonrpc":"2.0","result":"0xf8a46d"}
```


## Maintenance ##

Attach a shell to the bootnode:
```
docker exec -it <image_name> /bin/sh
```
