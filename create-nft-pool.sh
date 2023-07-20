#!/bin/bash

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8
export FIVE_PERCENT=50000000000000000

collateral_token=${1:?}
quote_token=${2:?}
token_ids=${3:-""}
quiet=${4:-0}

function log {
    if [[ $quiet == 0 ]]; then echo "$1"; fi
}
function fail {
    log "$1"
    exit 1
}

regex_pool_bytes='"data":"0x0{24}([0-9a-fA-F]+)'

pushd ../contracts > /dev/null
if [[ -z ${ERC721FACTORY} ]]; then fail "please set ERC721FACTORY address"; fi

cmd="cast send ${ERC721FACTORY} deployPool(address,address,uint256[],uint256) 
    ${collateral_token} ${quote_token} [${token_ids}] ${FIVE_PERCENT} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}"
output=$(${cmd})
log "${output}"
if [[ $output =~ $regex_pool_bytes ]]; then
    export POOL="0x${BASH_REMATCH[1]}"
    POOL=$(cast --to-checksum-address $POOL)
else
    fail "Could not determine pool address."
fi

if [[ $quiet == 0 ]]; then
    # tell the user what we just did
    echo Deployed pool to ${POOL}.
else
    # return token address to calling script
    echo ${POOL}
fi
