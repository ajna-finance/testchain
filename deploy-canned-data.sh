#!/bin/bash

mint_to=0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E

if [[ -z ${TOKENSFACTORY} ]]; then fail "please set TOKENSFACTORY address"; fi
if [[ -z ${ERC20FACTORY} ]]; then fail "please set ERC20FACTORY address"; fi

# Deploy tokens
TWETH=$(./create-token.sh "TestWrappedETH" TWETH 18 $mint_to 1000ether 1)
TDAI=$(./create-token.sh "TestDai" TDAI 18 $mint_to 500000ether 1)
TWBTC=$(./create-token.sh "TestWrappedBTC" TWBTC 8 $mint_to 25ether 1)
TUSDC=$(./create-token.sh "TestUSDC" TUSDC 6 $mint_to 500000ether 1)
TESTA=$(./create-token.sh "TestTokenA" TESTA 18 $mint_to 1000000ether 1)
TESTB=$(./create-token.sh "TestTokenB" TESTB 18 $mint_to 1000000ether 1)
TESTC=$(./create-token.sh "TestTokenC" TESTC 18 $mint_to 1000000ether 1)
TESTD=$(./create-token.sh "TestTokenD" TESTD 18 $mint_to 1000000ether 1)
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

# TODO: Add liquidity

# TODO: Draw debt