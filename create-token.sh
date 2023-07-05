#!/bin/bash
set -e

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8

token_name=${1:-TestToken}  # CAUTION: no spaces
token_symbol=${2:-TEST}
decimals=${3:-18}
mint_to=${4:-${DEPLOY_ADDRESS}}
amount=${5:-1000000ether}
quiet=${6:-0}

function log {
    if [[ $quiet == 0 ]]; then echo "$1"; fi
}
function fail {
    log "$1"
    exit 1
}

regex_token_address='logs[[:space:]]+\[\{"address":"([0-9xa-fA-F]+)","topics":'

if [[ -z ${TOKENSFACTORY} ]]; then fail "please set TOKENSFACTORY address"; fi

# create the token
cmd="cast send ${TOKENSFACTORY} createERC20Token(string,string,uint8) 
    ${token_name} ${token_symbol} ${decimals} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}"
output=$(${cmd})
log "${output}"
if [[ $output =~ $regex_token_address ]]; then
    export TOKEN=${BASH_REMATCH[1]}
else
    fail "Could not determine token address."
fi

# mint to the specified address
output=$(cast send ${TOKEN:?} "mint(address,uint256)" ${mint_to} ${amount} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY})
log "${output}"
TOKEN=$(cast --to-checksum-address $TOKEN)

if [[ $quiet == 0 ]]; then
    # tell the user what we just did
    echo Deployed ${token_symbol} to ${TOKEN} and minted ${amount} to ${mint_to}.
else
    # return token address to calling script
    echo ${TOKEN}
fi
