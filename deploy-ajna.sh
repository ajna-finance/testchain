#!/bin/bash

# terminate with message upon error
function fail {
    echo Deployment failed.
    exit 1
}

# set up environment for the ganache container
export ETH_RPC_URL=http://0.0.0.0:8555
export DEPLOY_ADDRESS=0xeeDC2EE00730314b7d7ddBf7d19e81FB7E5176CA
export DEPLOY_RAWKEY=0xd332a346e8211513373b7ddcf94b2b513b934b901258a9465c76d0d9a2b676d8

echo Deploying AJNA to ${ETH_RPC_URL:?}

# regular expressions to pluck addresses from deployment logs
regex_ajna_token_address="AJNA token deployed to ([0-9xa-fA-F]+)"
regex_grantfund_address="GrantFund deployed to ([0-9xa-fA-F]+)"
regex_erc20_factory_address="ERC20\s+factory\s+([0-9xa-fA-F]+)"
regex_erc721_factory_address="ERC721\s+factory\s+([0-9xa-fA-F]+)"
regex_poolinfoutils_address="PoolInfoUtils\s+([0-9xa-fA-F]+)"
regex_positionmanager_address="PositionManager\s+([0-9xa-fA-F]+)"
regex_rewardsmanager_address="RewardsManager\s+([0-9xa-fA-F]+)"
regex_tokensfactory_address="TokensFactory deployed to ([0-9xa-fA-F]+)"

# Test to ensure user cloned repositories into expected locations.
pushd ../ecosystem-coordination && popd || fail
pushd ../contracts && popd || fail
pushd ../tokens-factory && popd || fail

# "forge script" cannot use the forked AJNA token, so deploy a new one to the fork
pushd ../ecosystem-coordination
export MINT_TO_ADDRESS=${DEPLOY_ADDRESS}
deploy_cmd="forge script script/AjnaToken.s.sol:DeployAjnaToken \
		    --rpc-url ${ETH_RPC_URL} --sender ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} --broadcast -vvv"
output=$(${deploy_cmd})
if [[ $output =~ $regex_ajna_token_address ]]
then
    export AJNA_TOKEN=${BASH_REMATCH[1]}
else
    echo $output
    echo Could not determine AJNA token address.
    popd && fail
fi
# since we minted 2bbn, burn half the tokens
cast send ${AJNA_TOKEN} "burn(uint256)" 1000000000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null

# deploy GrantFund
# modify source to set correct AJNA_TOKEN address
deploy_cmd="forge script script/GrantFund.s.sol:DeployGrantFund \
	            --rpc-url ${ETH_RPC_URL} --sender ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} --broadcast -vvv"
output=$(${deploy_cmd})
if [[ $output =~ $regex_grantfund_address ]]
then
    export GRANTFUND=${BASH_REMATCH[1]}
else
    echo $output
    echo Could not determine GrantFund address.
    popd && fail
fi

# fund GrantFund with 300mm AJNA
cast send ${AJNA_TOKEN} "approve(address,uint256)" ${GRANTFUND} 300000000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null
cast send ${GRANTFUND} "fundTreasury(uint256)" 300000000ether --from $DEPLOY_ADDRESS --private-key $DEPLOY_RAWKEY > /dev/null

# TODO: call startDistributionPeriod()


# deploy everything in the contracts repository
pushd ../contracts
deploy_cmd="forge script ./script/deploy.s.sol \
		    --rpc-url ${ETH_RPC_URL} --sender ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} --broadcast -vvv"
output=$(${deploy_cmd})
if [[ $output =~ $regex_erc20_factory_address ]]
then
    export ERC20FACTORY=${BASH_REMATCH[1]}
else
    echo $output
    echo Could not determine ERC20 factory address.
    popd && fail
fi
if [[ $output =~ $regex_erc721_factory_address ]]
then
    export ERC721FACTORY=${BASH_REMATCH[1]}
else
    echo Could not determine ERC721 factory address.
    popd && fail
fi
if [[ $output =~ $regex_poolinfoutils_address ]]
then
    export POOLINFOUTILS=${BASH_REMATCH[1]}
else
    echo Could not determine PoolInfoUtils address.
    popd && fail
fi
if [[ $output =~ $regex_positionmanager_address ]]
then
    export POSITIONMANAGER=${BASH_REMATCH[1]}
else
    echo Could not determine PositionManager address.
    popd && fail
fi
if [[ $output =~ $regex_rewardsmanager_address ]]
then
    export REWARDSMANAGER=${BASH_REMATCH[1]}
else
    echo Could not determine RewardsManager address.
    popd && fail
fi

# deploy test token factory
pushd ../tokens-factory
deploy_cmd="forge script script/DeployTokensFactory.s.sol:DeployTokensFactory --fork-block-number 1 \
            --rpc-url ${ETH_RPC_URL} --sender ${DEPLOY_ADDRESS} --private-key ${DEPLOY_RAWKEY} --broadcast -vvv"
output=$(${deploy_cmd})
if [[ $output =~ $regex_tokensfactory_address ]]
then
    export TOKENSFACTORY=${BASH_REMATCH[1]}
else
    echo $output
    echo Could not determine TokensFactory address.
    popd && fail
fi
popd

# print all the addresses
echo === Local Testchain Addresses ===
echo "AJNA token      ${AJNA_TOKEN}"
echo "GrantFund       ${GRANTFUND}"
echo "ERC20 factory   ${ERC20FACTORY}"
echo "ERC721 factory  ${ERC721FACTORY}"
echo "PoolInfoUtils   ${POOLINFOUTILS}"
echo "PositionManager ${POSITIONMANAGER}"
echo "RewardsManager  ${REWARDSMANAGER}"
echo "TokensFactory   ${TOKENSFACTORY}"
