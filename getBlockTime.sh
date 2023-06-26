#!/bin/bash

# Define the Ganache URL (provided as a command-line argument)
GANACHE_URL=$1

# Check if the ganache argument is provided
if [ -z "$GANACHE_URL" ]; then
    echo "Please provide the ganache url as a command-line argument."
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