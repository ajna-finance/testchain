#!/bin/bash

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8
export ERC20_NON_SUBSET_HASH=2263c4378b4920f0bef611a3ff22c506afa4745b3319c50b6d704a874990b8b2
export FIVE_PERCENT=50000000000000000

collateral_token=${1:?}
quote_token=${2:?}
quiet=${3:-0}

pushd ../contracts > /dev/null

function log {
    if [[ $quiet == 0 ]]; then echo "$1"; fi
}
function fail {
    log "$1"
    popd || exit 1
}

regex_pool_bytes='"data":"0x0{24}([0-9a-fA-F]+)'

pushd ../contracts > /dev/null
if [[ -z ${ERC20FACTORY} ]]; then fail "please set ERC20FACTORY address"; fi

cmd="cast send ${ERC20FACTORY} deployPool(address,address,uint256) 
    ${collateral_token} ${quote_token} ${FIVE_PERCENT} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}"
output=$(${cmd})
log "${output}"
if [[ $output =~ $regex_pool_bytes ]]; then
    export POOL="0x${BASH_REMATCH[1]}"
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

popd > /dev/null
