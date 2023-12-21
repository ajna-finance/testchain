#!/bin/bash
set -e

function fail {
    echo "$1"
    exit 1
}

if [[ -z ${TOKENSFACTORY} ]]; then fail "please set TOKENSFACTORY address"; fi
if [[ -z ${ERC20FACTORY} ]]; then fail "please set ERC20FACTORY address"; fi
if [[ -z ${ERC721FACTORY} ]]; then fail "please set ERC721FACTORY address"; fi
if [[ -z ${GRANTFUND} ]]; then fail "please set GRANTFUND address"; fi
if [[ -z ${AJNA_TOKEN} ]]; then fail "please set AJNA_TOKEN address"; fi


export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8
export LENDER_ADDRESS=0xbC33716Bb8Dc2943C0dFFdE1F0A1d2D66F33515E
export LENDER_KEY=0x2bbf23876aee0b3acd1502986da13a0f714c143fcc8ede8e2821782d75033ad1
export BORROWER_ADDRESS=0xD293C11Cd5025cd7B2218e74fd8D142A19833f74
export BORROWER_KEY=0x997f91a295440dc31eca817270e5de1817cf32fa99adc0890dc71f8667574391

# Deploy tokens
TWETH=$(./create-erc20-token.sh TestWrappedETH TWETH 18 $DEPLOY_ADDRESS 1000ether 1)
TDAI=$(./create-erc20-token.sh TestDai TDAI 18 $DEPLOY_ADDRESS 500000ether 1)
TWBTC=$(./create-erc20-token.sh TestWrappedBTC TWBTC 8 $DEPLOY_ADDRESS 25ether 1)
TUSDC=$(./create-erc20-token.sh TestUSDC TUSDC 6 $DEPLOY_ADDRESS 500000ether 1)
TESTA=$(./create-erc20-token.sh TestTokenA TESTA 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTB=$(./create-erc20-token.sh TestTokenB TESTB 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTC=$(./create-erc20-token.sh TestTokenC TESTC 18 $DEPLOY_ADDRESS 1000000ether 1)
TESTD=$(./create-erc20-token.sh TestTokenD TESTD 18 $DEPLOY_ADDRESS 1000000ether 1)
echo "Deployed TWETH to ${TWETH:?}"
echo "Deployed TDAI  to ${TDAI}"
echo "Deployed TWBTC to ${TWBTC}"
echo "Deployed TUSDC to ${TUSDC}"
echo "Deployed TESTA to ${TESTA}"
echo "Deployed TESTB to ${TESTB}"
echo "Deployed TESTC to ${TESTC}"
echo "Deployed TESTD to ${TESTD}"
TDUCK=$(./create-nft.sh TestDuckies TDUCK 1 )
TGOOSE=$(./create-nft.sh TestGeese TGOOSE 1 )
TLOON=$(./create-nft.sh TestLoon TLOON 1 )
echo "Deployed TDUCK to ${TDUCK:?}"
echo "Deployed TGOOSE to ${TGOOSE}"
echo "Deployed TLOON to ${TLOON}"
echo

# Deploy pools
POOLA=$(./create-erc20-pool.sh $TESTA $TDAI 1)
POOLB=$(./create-erc20-pool.sh $TESTB $TDAI 1)
POOLC=$(./create-erc20-pool.sh $TESTC $TDAI 1)
POOLD=$(./create-erc20-pool.sh $TESTD $TDAI 1)
POOLWBTCDAI=$(./create-erc20-pool.sh $TWBTC $TDAI 1)  # 8-18 decimal pool
POOLWETHUSDC=$(./create-erc20-pool.sh $TWETH $TUSDC 1) # 18-6 decimal pool
POOLWBTCUSDC=$(./create-erc20-pool.sh $TWBTC $TUSDC 1) # 8-6 decimal pool
echo TESTA-TDAI pool deployed to $POOLA
echo TESTB-TDAI pool deployed to $POOLB
echo TESTC-TDAI pool deployed to $POOLC
echo TESTD-TDAI pool deployed to $POOLD
echo TWBTC-TDAI pool deployed to $POOLWBTCDAI
echo TWETH-TUSDC pool deployed to $POOLWETHUSDC
echo TWBTC-TUSDC pool deployed to $POOLWBTCUSDC
POOLDUCK=$(./create-nft-pool.sh $TDUCK $TDAI "" 1)
POOLGOOSE=$(./create-nft-pool.sh $TGOOSE $TDAI "15,17,19,21,23,25,27,29,31,33" 1)
POOLLOON=$(./create-nft-pool.sh $TLOON $TDAI "16,18,20,22,24,26,28,30,32,34" 1)
echo TDUCK-TDAI pool deployed to $POOLDUCK
echo TGOOSE-TDAI pool deployed to $POOLGOOSE
echo TLOON-TDAI pool deployed to $POOLLOON
echo

# Provision tokens to actors
eoas=(
    ${LENDER_ADDRESS}
    ${BORROWER_ADDRESS}
    "0xb240043d57f11a0253743566C413bB8B068cb1F2"
    "0x6f386a7a0EF33b7927bBF86bf06414884a3FDFE5"
    "0x122230509E5bEEd0ea3c20f50CC87e0CdB9d7e1b"
    "0xB932C1F1C422D39310d0cb6bE57be36D356fc0c8"
    "0x9A7212047c046a28E699fd8737F2b0eF0F94B422"
    "0x7CA0e91795AD447De38E4ab03b8f1A829F38cA58"
    "0xd21BB9dEF715C0E7A1b7F18496F2475bcDeFA1Be"
    "0xef62E4A54bE04918f435b7dF83c01138521C009b"
    "0xAecE01e5Ba6B171455B97FBA91b33E1b138AF60c"
    "0x9D3904CD72d3BDb97C3B2e266A60aBe127B6F940"
    "0x2636aD85Da87Ff3780e1eC5e48fC0aBa33849B16"
    "0x81fFF6A381bF1aC11ed388124186C177Eb8623f4"
    "0x8596d963e0DEBCa873A56FbDd2C9d119Aa0eB443"
)
tokenId=20 # first 20 tokens are implicitly minted to the deploy address
for address in ${eoas[@]}; do
    echo "Provisioning tokens               to $address"
    cast send ${TWETH:?} "transfer(address,uint256)" $address 50ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TDAI "transfer(address,uint256)" $address 200000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TWBTC "transfer(address,uint256)" $address 400000000 --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null    # 4 TWBTC
    cast send $TUSDC "transfer(address,uint256)" $address 300000000000 --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null # 300_000 USDC
    cast send $TESTA "transfer(address,uint256)" $address 11000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TESTB "transfer(address,uint256)" $address 12000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TESTC "transfer(address,uint256)" $address 13000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TESTD "transfer(address,uint256)" $address 14000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $AJNA_TOKEN "transfer(address,uint256)" $address 5000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    echo "Provisioning NFTs with tokenId $tokenId to $address"
    cast send $TDUCK "mint(address,uint256)" $address $tokenId --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TGOOSE "mint(address,uint256)" $address $tokenId --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    cast send $TLOON "mint(address,uint256)" $address $tokenId --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
    ((tokenId++))
done
echo

# Add liquidity to fungible pool
echo Approving POOLA to spend lender\'s tokens
cast send ${TESTA:?} "approve(address,uint256)" ${POOLA:?} 20ether --from $LENDER_ADDRESS --private-key $LENDER_KEY > /dev/null
cast send $TDAI "approve(address,uint256)" $POOLA 100000ether --from $LENDER_ADDRESS --private-key $LENDER_KEY > /dev/null
echo Lender adding liquidity to POOLA
# TIMESTAMP=$(printf "%d" $(cast rpc eth_getBlockByNumber "latest" "false" | jq '.timestamp'))
TIMESTAMP=$(date -u +%s)
EXPIRY=$(( $TIMESTAMP + 86400 ))
cast send $POOLA "addCollateral(uint256,uint256,uint256)" 3.1ether 3220 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY > /dev/null
# NOTE: explicit gas limit must be set for reliable addQuoteToken execution
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 8000ether 3236 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY --gas-limit 1000000 > /dev/null
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 12000ether 3242 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY --gas-limit 1000000 > /dev/null
cast send $POOLA "addQuoteToken(uint256,uint256,uint256)" 5000ether 3261 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY --gas-limit 1000000 > /dev/null
# NOTE: "cut" is used to strip unwanted prettified scientific notation from forge output (a recent breaking change)
echo Pool size: $( cast --to-unit $( cast call $POOLA "depositSize()(uint256)" | cut -f1 -d" " ) ether )

# Draw debt from fungible pool
echo Approving POOLA to spend borrower\'s tokens
cast send $TESTA "approve(address,uint256)" $POOLA 4000ether --from $BORROWER_ADDRESS --private-key $BORROWER_KEY > /dev/null
cast send $TDAI "approve(address,uint256)" $POOLA 10300ether --from $BORROWER_ADDRESS --private-key $BORROWER_KEY > /dev/null
echo Borrower drawing debt from POOLA
DEBT=10000; PRICE=100; CR=1.3
COLLATERAL=$(echo "$DEBT / $PRICE * $CR / 1" | bc)
cast send $POOLA "drawDebt(address,uint256,uint256,uint256)" $BORROWER_ADDRESS ${DEBT}ether 3260 ${COLLATERAL}ether --from $BORROWER_ADDRESS --private-key $BORROWER_KEY --gas-limit 1000000 > /dev/null
echo Pool debt: $( cast --to-unit $(cast call $POOLA "debtInfo()(uint256,uint256,uint256)" | head -1 | cut -f1 -d" " ) ether )
echo

# Add liquidity to nonfungible pool
echo Approving POOLDUCK to spend lender\'s TDAI
cast send $TDAI "approve(address,uint256)" $POOLDUCK 100000ether --from $LENDER_ADDRESS --private-key $LENDER_KEY > /dev/null
echo Lender adding liquidity to POOLDUCK
cast send $POOLDUCK "addQuoteToken(uint256,uint256,uint256)" 6000ether 2909 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY --gas-limit 1000000 > /dev/null
cast send $POOLDUCK "addQuoteToken(uint256,uint256,uint256)" 4000ether 2920 $EXPIRY --from $LENDER_ADDRESS --private-key $LENDER_KEY --gas-limit 1000000 > /dev/null
echo Pool size: $( cast --to-unit $( cast call $POOLDUCK "depositSize()(uint256)" | cut -f1 -d" " ) ether )

# Draw debt from nonfungible pool
echo Approving POOLDUCK to spend borrower\'s NFT
cast send $TDUCK "setApprovalForAll(address,bool)" $POOLDUCK true --from $BORROWER_ADDRESS --private-key $BORROWER_KEY > /dev/null
echo Borrower drawing debt from POOLDUCK
cast send $POOLDUCK "drawDebt(address,uint256,uint256,uint256[])" $BORROWER_ADDRESS 435ether 7388 [21] --from $BORROWER_ADDRESS --private-key $BORROWER_KEY --gas-limit 1000000 > /dev/null
echo Pool debt: $( cast --to-unit $(cast call $POOLDUCK "debtInfo()(uint256,uint256,uint256)" | head -1 | cut -f1 -d" " ) ether )
echo

# start a new distribution period
# FIXME: this reverts with "result": String("0xd7483288")
cast send ${GRANTFUND:?} "startNewDistributionPeriod()" --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null

# Take an EVM snapshot
./getBlockTime.sh $ETH_RPC_URL
echo Taking evm_snapshot of initial state
cast rpc evm_snapshot
echo
