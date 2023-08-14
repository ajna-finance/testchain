# Testchain #
The purpose of this project is to set up a local testchain for testing Ajna deployment and integration testing.

## Prerequisites ##
* `docker` and `compose` plugin (or `docker-compose` package)
* `foundry` tools (installation documented in `contracts` repository)
* `bc` and `jq` tools

## Setup ##

Clone the following Ajna GitHub repositories.  Either check them out in the same location you cloned this `testchain` repository, or establish symlinks as needed.
- https://github.com/ajna-finance/contracts
- https://github.com/ajna-finance/ecosystem-coordination
- https://github.com/ajna-finance/tokens-factory

In each repository, switch to whichever branch is appropriate for the testchain, and `make build`.
Because `forge script` arguments conflict with _foundry_ configuration, comment out `block_number` and `fork_block_number` in `foundry.toml`.

### Create a docker image with a local testnet ###
The included `docker-compose.yml` creates a single instance of `ganache` and uses a wallet seed for consistant account generation.

```
docker compose up
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

Source the deployment script, such that environment is updated with new deployment addresses.
```
source ./deploy-ajna.sh
```

Record addresses printed by the deployment script here:
```
=== Local Testchain Addresses ===
AJNA token      0x25Af17eF4E2E6A4A2CE586C9D25dF87FD84D4a7d
BurnWrapper     0xE340B87CEd1af1AbE1CE8D617c84B7f168e3b18b
GrantFund       0x0b3A0ea1Fc7207d3e3ed9973025dA9d0e8fb0F3f
ERC20 factory   0x9617ABE221F9A9c492D5348be56aef4Db75A692d
ERC721 factory  0x4f05DA51eAAB00e5812c54e370fB95D4C9c51F21
PoolInfoUtils   0x6c5c7fD98415168ada1930d44447790959097482
PositionManager 0x6548dF23A854f72335902e58a1e59B50bb3f11F1
RewardsManager  0xdF7403003a16c49ebA5883bB5890d474794cea5a
TokensFactory   0x9a56e5e70373E4965AAAFB994CB58eDC577031D7
```

### Create test tokens and pools ###

To facilitate testing, create some test tokens and pools by running `./deploy-canned-data.sh`.  This script will create several artifacts:
* 8 ERC-20 test tokens: 4 mimicing popular tokens with appropriate decimal places, and 4 with no implied price.  All tokens get minted to address[0] from the list above.
* 3 ERC-721 NFTs: the first 20 tokens are minted to the deployer, each user gets a subsequent tokenId for all three.
* 7 fungible pools:
  * `TESTA-TDAI` - Assume market price of TESTA is 100 DAI.  Lender 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E adds liquidity to buckets as follows:
    | index | price   | deposit | collateral |
    |-------|--------:|--------:|-----------:|
    | 3220  | 106.520 | 0       | 3.1        |
    | 3236  |  98.350 | 8000    | 0          |
    | 3242  |  95.450 | 12000   | 0          |
    | 3261  |  86.821 | 5000    | 0          |

    Borrower 0xD293C11Cd5025cd7B2218e74fd8D142A19833f74 draws 10k debt, bringing LUP index to 3242.
  * `TESTB-TDAI`, `TESTC-TDAI`, `TESTD-TDAI` - empty 18-decimal pools
  * `TWBTC-TDAI` - empty 12/18-decimal pool
  * `TWETH-TUSDC` - empty 18/8-decimal pool
  * `TWBTC-TUSDC` - empty 12/8-decimal pool
* 3 nonfungible pools:
  * `TDUCK-TDAI` - Collection pool.  Assume floor price of TDUCK is 500 DAI.  Lender 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E adds liquidity to buckets as follows:
    | index | price   | deposit | collateral |
    |-------|--------:|--------:|-----------:|
    | 2909  | 502.434 | 6000    | 0          |
    | 2920  | 475.611 | 4000    | 0          |

  * `TGOOSE-TDAI` - Empty subset pool accepting odd-numbered tokenIds 15-33.
  * `TLOON-TDAI` - Empty subset pool accepting even-numbered tokenIds 16-34.

Output should look like this:
```
Deployed TWETH to 0x844f3C269f301f89D81f29B91b8d8ED2C69Fa7Bc
Deployed TDAI  to 0x4cEDCBb309d1646F3E91FB00c073bB28225262E6
Deployed TWBTC to 0x983e8657Fb6450fca862a96BcAF461Ede2AaAE27
Deployed TUSDC to 0x606A640CB77AeCBfefe918AebDCB34845FF18546
Deployed TESTA to 0xf6C45B3B42b910110B1c750C959D0a396470c520
Deployed TESTB to 0x3f2D7987bffe953f071273F3ABc99154ba3BAE99
Deployed TESTC to 0x29eb88824f9F118B2aA975F6919D4a85189c9823
Deployed TESTD to 0x1353F826e463782e084cf1f238662E40D32DD29d
Deployed TDUCK to 0xaf36Ce3FD234ba81A9d4676CD09fC6700f087146
Deployed TGOOSE to 0x5D94D2fa949Ac3127C27CB344882fAafE70665Df
Deployed TLOON to 0xD933Ee26bB6bF3d6c4A769ECb0FC0D43fC5d52BD

TESTA-TDAI pool deployed to 0x845e5B204859f61b1EE99D60A9ff440d972Cde1C
TESTB-TDAI pool deployed to 0x46f65d2c707ea9c15D398889cEF64C0C373bFdA7
TESTC-TDAI pool deployed to 0x066E979d2533443E14Bb17807c5a94c532c2E9ec
TESTD-TDAI pool deployed to 0xe8dCc8FbAb00cF7911944dE5f9080Ecd9f25d3A9
TWBTC-TDAI pool deployed to 0xa390765fB18EdCBC15dc9e2d56D9FC33c1a3FAcb
TWETH-TUSDC pool deployed to 0x59e75F304a499cBa0FF2cd4eC7eee445B964F2B8
TWBTC-TUSDC pool deployed to 0x5c6631E917f89882294F3edD18A067E47c9093cE
TDUCK-TDAI pool deployed to 0xa1542c7f2e2EFB039893BAD7D663BE292e41a683
TGOOSE-TDAI pool deployed to 0xEbca0ef5Da3A6AEc286dd8859817cF771A24D717
TLOON-TDAI pool deployed to 0xadFadef7bfB285Bb1823A0A2b3708cac5EeA56A7

Provisioning tokens               to 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E
Provisioning NFTs with tokenId 20 to 0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E
Provisioning tokens               to 0xD293C11Cd5025cd7B2218e74fd8D142A19833f74
Provisioning NFTs with tokenId 21 to 0xD293C11Cd5025cd7B2218e74fd8D142A19833f74
Provisioning tokens               to 0xb240043d57f11a0253743566C413bB8B068cb1F2
Provisioning NFTs with tokenId 22 to 0xb240043d57f11a0253743566C413bB8B068cb1F2
Provisioning tokens               to 0x6f386a7a0EF33b7927bBF86bf06414884a3FDFE5
Provisioning NFTs with tokenId 23 to 0x6f386a7a0EF33b7927bBF86bf06414884a3FDFE5
Provisioning tokens               to 0x122230509E5bEEd0ea3c20f50CC87e0CdB9d7e1b
Provisioning NFTs with tokenId 24 to 0x122230509E5bEEd0ea3c20f50CC87e0CdB9d7e1b
Provisioning tokens               to 0xB932C1F1C422D39310d0cb6bE57be36D356fc0c8
Provisioning NFTs with tokenId 25 to 0xB932C1F1C422D39310d0cb6bE57be36D356fc0c8
Provisioning tokens               to 0x9A7212047c046a28E699fd8737F2b0eF0F94B422
Provisioning NFTs with tokenId 26 to 0x9A7212047c046a28E699fd8737F2b0eF0F94B422
Provisioning tokens               to 0x7CA0e91795AD447De38E4ab03b8f1A829F38cA58
Provisioning NFTs with tokenId 27 to 0x7CA0e91795AD447De38E4ab03b8f1A829F38cA58
Provisioning tokens               to 0xd21BB9dEF715C0E7A1b7F18496F2475bcDeFA1Be
Provisioning NFTs with tokenId 28 to 0xd21BB9dEF715C0E7A1b7F18496F2475bcDeFA1Be
Provisioning tokens               to 0xef62E4A54bE04918f435b7dF83c01138521C009b
Provisioning NFTs with tokenId 29 to 0xef62E4A54bE04918f435b7dF83c01138521C009b
Provisioning tokens               to 0xAecE01e5Ba6B171455B97FBA91b33E1b138AF60c
Provisioning NFTs with tokenId 30 to 0xAecE01e5Ba6B171455B97FBA91b33E1b138AF60c
Provisioning tokens               to 0x9D3904CD72d3BDb97C3B2e266A60aBe127B6F940
Provisioning NFTs with tokenId 31 to 0x9D3904CD72d3BDb97C3B2e266A60aBe127B6F940
Provisioning tokens               to 0x2636aD85Da87Ff3780e1eC5e48fC0aBa33849B16
Provisioning NFTs with tokenId 32 to 0x2636aD85Da87Ff3780e1eC5e48fC0aBa33849B16
Provisioning tokens               to 0x81fFF6A381bF1aC11ed388124186C177Eb8623f4
Provisioning NFTs with tokenId 33 to 0x81fFF6A381bF1aC11ed388124186C177Eb8623f4
Provisioning tokens               to 0x8596d963e0DEBCa873A56FbDd2C9d119Aa0eB443
Provisioning NFTs with tokenId 34 to 0x8596d963e0DEBCa873A56FbDd2C9d119Aa0eB443

Approving POOLA to spend lender's tokens
Lender adding liquidity to POOLA
Pool size: 25000
Approving POOLA to spend borrower's tokens
Borrower drawing debt from POOLA
Pool debt: 10009.615384615384620000

Approving POOLDUCK to spend lender's TDAI
Lender adding liquidity to POOLDUCK
Pool size: 10000
Approving POOLDUCK to spend borrower's NFT
Borrower drawing debt from POOLDUCK
Pool debt: 435.418269230769230970

Latest block number: 247
Latest block timestamp: 1691812001
Latest block date: Fri Aug 11 23:46:41 2023
```

Ensure pool size and pool debt is appropriate. After execution, update the text above with new token and pool addresses.


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

To authenticate, run `docker login ghcr.io` using your GitHub username and paste your GitHub token as the password.  To publish, run the publishing script passing the release label as an argument:
```
./publish.sh rc6
```

Visit [Ajna packages](https://github.com/orgs/ajna-finance/packages) and confirm the package has updated.

## Maintenance ##

Attach a shell to the bootnode:
```
docker exec -it <image_name> /bin/sh
```

## Utility Scripts

*GANACHE_URL is taken either from your computer's environment variable ETH_RPC_URL or from command input*
  
To jump in time with `evm_increaseTime`

```
./jump.sh NUMBER_OF_SECONDS GANACHE_URL
```

To reset to the initial snapshot. Be aware that Subgraph doesn't work well with Ganache and after reverting to snapshot, all Subgraph's data will remain.

```
./reset.sh GANACHE_URL
```

To check the latest block number and block time

```
./getBlockTime.sh GANACHE_URL
```
