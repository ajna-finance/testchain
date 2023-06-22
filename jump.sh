#!/bin/bash

# Define the time to jump in seconds and ganache instance (provided as a command-line argument)
TIME_TO_JUMP=$1
GANACHE_URL=$2

# Check if the time argument is provided
if [ -z "$TIME_TO_JUMP" ]; then
    echo "Please provide the time to jump in seconds as a command-line argument."
    exit 1
fi

# Check if the ganache argument is provided
if [ -z "$GANACHE_URL" ]; then
    echo "Please provide the ganache url as a command-line argument."
    exit 1
fi


# # Call evm_increaseTime to jump the time
increase_time_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"evm_increaseTime","params":['"$TIME_TO_JUMP"'],"id":1}' $GANACHE_URL)
increase_time_result=$(echo $increase_time_response | jq -r '.result')

# Check if evm_increaseTime was successful
if (( increase_time_result > 0 )); then
    echo "Time increased by $TIME_TO_JUMP seconds."
else
    echo "Failed to increase time."
    exit 1
fi


# Call evm_mine to mine a new block
mine_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"evm_mine","params":[],"id":1}' $GANACHE_URL)
mine_result=$(echo $mine_response | jq -r '.result')

# Check if evm_mine was successful
if [ "$mine_result" == 0x0 ]; then
    echo "New block mined."
else
    echo "Failed to mine a new block."
    exit 1
fi

# Call eth_blockNumber to get the latest block number
block_number_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $GANACHE_URL)
block_number=$(echo $block_number_response | jq -r '.result')

# Convert the block number from hexadecimal to decimal
block_number_decimal=$(printf "%d" $block_number)

# Call eth_getBlockByNumber to get the latest block details
block_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", true],"id":1}' $GANACHE_URL)
block_data=$(echo $block_response | jq '.result')

block_timestamp=$(echo $block_data | jq -r '.timestamp')

if [ "$block_timestamp" == "null" ]; then
    echo "Latest block is pending and does not have a timestamp yet."
else
    decimal_date=$(printf "%d" $block_timestamp)
    readable_date=$(date -r $block_timestamp)

    echo "Latest block number: $block_number_decimal"
    echo "Latest block timestamp: $decimal_date"
    echo "Latest block date: $readable_date"
fi