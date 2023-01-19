# Testchain #
The purpose of this project is to setup a local testchain for testing Ajna deployment and integration testing.

## Prerequisites ##
You'll need `docker` and `docker-compose` installed.

## Setup ##

### Create a docker image with a local testnet ###
This creates two instances of `geth`: a bootnode for peer discovery and a JSON-RPC endpoint for fulfilling test requests.
The testchain is configured to fund a known account with 1000 ETH.  The included `.env` file provides account details for this account and the path to the JSON keystore.  A nonstandard port is used to avoid conflict with other local JSON-RPC endpoints.

```
docker-compose up

```

With the testchain up, run the following command to check your ETH balance:
```
curl localhost:8555 -X POST -H "Content-Type: application/json" --data '{
    "jsonrpc": "2.0", "id":1, 
    "method": "eth_getBalance",
    "params": [
        "'${DEPLOY_ADDRESS}'",
        "latest"
    ]
}'
```

You should receive the following response, indicating the account has 1000 ETH:
```
{"jsonrpc":"2.0","id":4,"result":"0x3635c9adc5dea00000"}
```

### Deploy Ajna to the testnet ###

From another terminal, update `../contracts/Makefile` (specifically the `forge script` command under the _deploy-contracts_ target) by setting `--fork-block-number 1`.  Then run the following script which automates deploying Ajna to this chain:
```
./deploy-ajna.sh
```
You will be prompted three times to enter the keystore password, found at the bottom of `.env`.


### Persist changes ###
Record the address printed by the deployment script here:
```
=== Local Testchain Addresses ===
AJNA token      0x8BBCA51044d00dbf16aaB8Fd6cbC5B45503B898b
GrantFund       0xED625fbf62695A13d2cADEdd954b23cc97249988
ERC20 factory   0x6BB39D90ed1ce618503fd470BB99F44EB93681f3
ERC721 factory  0x46Cd1f7fda93Fee1C667FB77A50782500176C311
PoolInfoUtils   0xaeeeDaCda29B43fEfa6Dcd215B51e0915B5A5060
PositionManager 0xDFC39eE18739D3bF548A2e1815e0382889CD839F
RewardsManager  0x36B3bCe82C4AB0d5b238de6e833b9b15689dEf8b
```


Update any dependent repositories (such as _sdk_) with the new addresses.

Run `docker commit testnet ajna/testnet` to save the image.


## Maintenance ##

Attach a shell to the bootnode:
```
docker exec -it ajna-testchain_geth-bootnode_1 /bin/sh
```
