# Testchain #
The purpose of this project is to setup a local testchain for testing Ajna deployment and integration testing.

## Prerequisites ##
You'll need `docker` and `docker-compose` installed.

## Setup ##
This creates two instances of `geth`: a bootnode for peer discovery and a JSON-RPC endpoint for fulfilling test requests.
The testchain is configured to fund a known account with 1000 ETH.  The included `.env` file provides account details for this account and the path to the JSON keystore.

```
docker-compose up

```

With the testchain up, run the following command to check your ETH balance:
```
curl --location --request POST 'localhost:8545' \
--header 'Content-Type: application/json' \
--data-raw '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "eth_getBalance",
    "params": [
        ${DEPLOYMENT_ADDRESS},
        "latest"
    ]
}'
```

You should receive the following response, indicating the account has 1000 ETH:
```
{"jsonrpc":"2.0","id":4,"result":"0x3635c9adc5dea00000"}
```


## Maintenance ##

Attach a shell to the bootnode:
```
docker exec -it ajna-testchain_geth-bootnode_1 /bin/sh
```
