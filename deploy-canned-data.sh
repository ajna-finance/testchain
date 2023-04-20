#!/bin/bash

if [[ -z ${TOKENSFACTORY} ]]; then fail "please set TOKENSFACTORY address"; fi
if [[ -z ${ERC20FACTORY} ]]; then fail "please set ERC20FACTORY address"; fi

export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8
export LENDER_ADDRESS=0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E
export LENDER_KEY=0x2bbf23876aee0b3acd1502986da13a0f714c143fcc8ede8e2821782d75033ad1
export BORROWER_ADDRESS=0xD293C11Cd5025cd7B2218e74fd8D142A19833f74
export BORROWER_KEY=0x997f91a295440dc31eca817270e5de1817cf32fa99adc0890dc71f8667574391

# Deploy tokens
TWETH=$(./create-token.sh "TestWrappedETH" TWETH 18 $DEPLOY_ADDRESS 1000ether 1)
TDAI=$(./create-token.sh "TestDai" TDAI 18 $DEPLOY_ADDRESS 500000ether 1)
TWBTC=$(./create-token.sh "TestWrappedBTC" TWBTC 8 $DEPLOY_ADDRESS 25ether 1)
TUSDC=$(./create-token.sh "TestUSDC" TUSDC 6 $DEPLOY_ADDRESS 500000ether 1)
TESTA=$(./create-token.sh "TestTokenA" TESTA 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTB=$(./create-token.sh "TestTokenB" TESTB 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTC=$(./create-token.sh "TestTokenC" TESTC 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTD=$(./create-token.sh "TestTokenD" TESTD 18 $DEPLOY_ADDRESS 1000000ether 1)
echo "Deployed TWETH to ${TWETH}"
echo "Deployed TDAI  to ${TDAI}"
echo "Deployed TWBTC to ${TWBTC}"
echo "Deployed TUSDC to ${TUSDC}"
echo "Deployed TESTA to ${TESTA}"
echo "Deployed TESTB to ${TESTB}"
echo "Deployed TESTC to ${TESTC}"
echo "Deployed TESTD to ${TESTD}"
echo

# Deploy pool
POOLA=$(./create-erc20-pool.sh $TESTA $TDAI 1)
echo TESTA-TDAI pool deployed to $POOLA
echo

# Provision tokens to actors
echo Provisioning tokens to lender $LENDER_ADDRESS
cast send $TESTA "transfer(address,uint256)" $LENDER_ADDRESS 20ether --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} > /dev/null
cast send $TDAI "transfer(address,uint256)" $LENDER_ADDRESS 100000ether --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} > /dev/null
echo Lender has $( cast --to-unit $( cast call $TDAI "balanceOf(address)(uint256)" $LENDER_ADDRESS ) ether ) TDAI

# echo Provisioning tokens to borrower $BORROWER_ADDRESS
cast send $TESTA "transfer(address,uint256)" $BORROWER_ADDRESS 4000ether --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} > /dev/null
cast send $TDAI "transfer(address,uint256)" $BORROWER_ADDRESS 300ether --from ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} > /dev/null
echo Borrower has $( cast --to-unit $( cast call $TESTA "balanceOf(address)(uint256)" $BORROWER_ADDRESS ) ether ) TESTA
echo

# Add liquidity
echo Approving POOLA to spend lender\'s tokens
cast send $TESTA "approve(address,uint256)" $POOLA 20ether --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY} > /dev/null
cast send $TDAI "approve(address,uint256)" $POOLA 100000000ether --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY} > /dev/null
echo Lender adding liquidity
# TIMESTAMP=$(printf "%d" $(cast rpc eth_getBlockByNumber "latest" "false" | jq '.timestamp'))
TIMESTAMP=$(date -u +%s)
EXPIRY=$(( $TIMESTAMP + 86400 ))
cast send $POOLA "addCollateral(uint256,uint256,uint256)" 3.1ether 3220 $EXPIRY --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY}
# NOTE: explicit gas limit must be set for reliable addQuoteToken execution
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 8000ether 3236 $EXPIRY --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY} --gas-limit 1000000
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 12000ether 3242 $EXPIRY --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY} --gas-limit 1000000
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 5000ether 3261 $EXPIRY --from ${LENDER_ADDRESS} --private-key ${LENDER_KEY} --gas-limit 1000000
echo Pool size: $( cast --to-unit $( cast call $POOLA "depositSize()(uint256)" ) ether )

# TODO: Draw debt