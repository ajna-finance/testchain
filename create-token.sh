#!/bin/bash

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8

token_name=${1:-"TestToken"}
token_symbol=${2:-"TEST"}
decimals=${3:-18}
mint_to=${4:-${DEPLOY_ADDRESS}}
amount=${5:-1000000ether}

regex_token_address='logs\s+\[\{"address":"([[0-9xa-fA-F]+)","topics":'

pushd ../contracts

# create the token
cmd="cast send ${TOKENSFACTORY:?} createERC20Token(string,string,uint8) 
    \"${token_name}\" \"${token_symbol}\" ${decimals} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}"
output=$(${cmd})
echo "${output}"
if [[ $output =~ $regex_token_address ]]
then
    export TOKEN=${BASH_REMATCH[1]}
else
    echo Could not determine token address.
    popd && exit 1
fi

# mint to the specified address
cast send ${TOKEN} "mint(address,uint256)" ${mint_to} ${amount} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}

# tell the user what we just did
echo Deployed ${token_symbol} to ${TOKEN} and minted ${amount} to ${mint_to}.

popd