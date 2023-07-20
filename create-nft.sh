#!/bin/bash

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8

token_name=${1:-TestToken}  # CAUTION: no spaces
token_symbol=${2:-TEST}
quiet=${3:-0}
token_baseuri=${4:-https://cloudflare-ipfs.com/ipfs}

function log {
    if [[ $quiet == 0 ]]; then echo "$1"; fi
}
function fail {
    log "$1"
    exit 1
}

regex_token_address='logs[[:space:]]+\[\{"address":"([0-9xa-fA-F]+)","topics":'

if [[ -z ${TOKENSFACTORY} ]]; then fail "please set TOKENSFACTORY address"; fi

# create the collection
cmd="cast send ${TOKENSFACTORY} createERC721Token(string,string,string) 
    ${token_name} ${token_symbol} ${token_baseuri} \
    --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY}"
output=$(${cmd})
log "${output}"
if [[ $output =~ $regex_token_address ]]; then
    export TOKEN=${BASH_REMATCH[1]}
    TOKEN=$(cast --to-checksum-address $TOKEN)
else
    fail "Could not determine token address."
fi

if [[ $quiet == 0 ]]; then
    # tell the user what we just did
    echo Deployed ${token_symbol} to ${TOKEN}.
else
    # return token address to calling script
    echo ${TOKEN}
fi
