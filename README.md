# Testchain #
The purpose of this project is to set up a local testchain for testing Ajna deployment and integration testing.

## Prerequisites ##
* `docker` and `docker-compose`
* a mainnet Ethereum node to create the fork
* `foundry` tools (installation documented in `contracts` repository)
* `bc` and `jq` tools

## Setup ##

First, set `ETH_RPC_URL` to a mainnet node.  The docker container will use this to fork mainnet.

Then, clone the following Ajna GitHub repositories.  Either check them out in the same location you cloned this `testchain` repository, or establish symlinks as needed.
- https://github.com/ajna-finance/contracts
- https://github.com/ajna-finance/ecosystem-coordination
- https://github.com/ajna-finance/tokens-factory

In each repository, switch to whichever branch is appropriate for the testchain, and `make build`.

### Create a docker image with a local testnet ###
The included `docker-compose.yml` creates a single instance of `ganache` and uses a wallet seed for consistant account generation.

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
ERC20 factory   0x12865F86F31e674738192cd3AE154485A6FCB2b6
ERC721 factory  0x06F4dC71a0029E31141fa23988735950324A48C7
PoolInfoUtils   0x9EF8ad06546EE0FbCB9927bC015b0ce7159c2e1e
PositionManager 0xD86c4A8b172170Da0d5C0C1F12455bA80Eaa42AD
RewardsManager  0x9617ABE221F9A9c492D5348be56aef4Db75A692d
TokensFactory   0xdF7403003a16c49ebA5883bB5890d474794cea5a
```

### Create test tokens and pools ###

To facilitate testing, create some test tokens and pools.  Export `TOKENSFACTORY` and `ERC20FACTORY` to addresses from above, and then run `./deploy-canned.data.sh`.  This script will create several artifacts:
* 8 test tokens: 4 mimicing popular tokens with appropriate decimal places, and 4 with no implied price.  All tokens get minted to address[0] from the list above.
* 4 pools:
  * `TESTA-DAI` - Assume market price of TESTA is 100 DAI. **(TODO)** Lender 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E adds liquidity to buckets as follows:
    | index | price   | deposit | collateral |
    |-------|--------:|--------:|-----------:|
    | 3220  | 106.520 | 0       | 3.1        |
    | 3236  |  98.350 | 8000    | 0          |
    | 3242  |  95.450 | 12000   | 0          |
    | 3261  |  86.821 | 5000    | 0          |

    Borrower 0xD293C11Cd5025cd7B2218e74fd8D142A19833f74 draws 10k debt, bringing LUP index to 3242.
  * `TESTB-DAI` - empty pool
  * `TESTC-DAI` - empty pool
  * `TESTD-DAI` - empty pool

Output should look like this:
```
Deployed TWETH to 0x7bd6b3c06ec9f9dc7a1658e52121c32c8fb76a4f
Deployed TDAI  to 0x9cd8f5eae0ef43b7e5e8ffc74b0899545250e3f3
Deployed TWBTC to 0x99bda273d542840bbaed6fec0165e1670d6de528
Deployed TUSDC to 0x40caafd8b7dd07409609720659d91e7894c9b315
Deployed TESTA to 0x2c1eee85197ba29e139c09c46cd546887e2749bd
Deployed TESTB to 0x3d7ce4d1e1dfd3839f71dd1819fb69eb02df889a
Deployed TESTC to 0xbf03bfa16f28686d23ae1e13ea6992275f69a251
Deployed TESTD to 0x3d694eeb6bcab80d4a309db2bd2f23f7b4bdb003

TESTA-TDAI pool deployed to 0x44a75e7692e30090e7c1988e9c7385d1fc6ffdb6
TESTB-TDAI pool deployed to 0xb0d5e3f5708bfa29c35fe07b1d706d93d7b00c54
TESTC-TDAI pool deployed to 0x94447cdfed5e6e5a847c5c1caa1186e71828f89d
TESTD-TDAI pool deployed to 0x1573fef83d35e209a898ebdf5acb3a560067df15

Provisioning tokens to lender 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E
Lender has 100000 TDAI
Borrower has 4000 TESTA

Approving POOLA to spend lender's tokens
Lender adding liquidity
Pool size: 25000

Approving POOLA to spend borrower's tokens
Borrower drawing debt
Pool debt: 10009.636539535804830288
```
Ensure pool size and pool debt is appropriate.
After execution, update the text above with new token and pool addresses.


### Persist changes ###

Check the block height, that you may later confirm whether you're working with a fresh deployment:
```
curl 0.0.0.0:8555 -X POST -H "Content-Type: application/json" --data '{
    "jsonrpc": "2.0", "id":2,
    "method": "eth_blockNumber",
    "params":[]
}'
```
You should receive a response like the following, which indicates a block height of 16295021:
```
{"id":2,"jsonrpc":"2.0","result":"0xf8a46d"}
```

### Publish the package ###

For first-time setup, visit [GitHub Developer Settings](https://github.com/settings/tokens) and create a new _personal access token (classic)_ with privileges to the _GitHub Package Repository_.  Set a reasonable expiration; the default is 7 days.  Record the token somewhere safe.

To authenticate, run `docker login ghcr.io` using your GitHub username and paste your GitHub token as the password.

To push the package to the GitHub Container Repository:
```
docker commit ajna-testnet ghcr.io/ajna-finance/ajna-testnet:<tag>
docker push ghcr.io/ajna-finance/ajna-testnet:<tag>
```
Visit [Ajna packages](https://github.com/orgs/ajna-finance/packages) and confirm the package has updated.

## Maintenance ##

Attach a shell to the bootnode:
```
docker exec -it <image_name> /bin/sh
```
