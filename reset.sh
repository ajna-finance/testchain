#!/bin/bash

# Define the Ganache URL (provided as a command-line argument)
GANACHE_URL=$1

# Check if the ganache argument is provided
if [ -z "$GANACHE_URL" ]; then
    echo "Please provide the ganache url as a command-line argument."
    exit 1
fi

# Define the snapshot ID to revert to
SNAPSHOT_ID=0x1

# Call evm_revert to revert the blockchain state to the specified snapshot ID
revert_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"evm_revert","params":["'$SNAPSHOT_ID'"],"id":1}' $GANACHE_URL)
revert_result=$(echo $revert_response | jq -r '.result')

# Check if evm_revert was successful
if [ "$revert_result" == "true" ]; then
    echo "Blockchain state reverted to snapshot ID: $SNAPSHOT_ID"
else
    echo "Failed to revert blockchain state."
    exit 1
fi

# Call evm_snapshot to create a snapshot of the current blockchain state
snapshot_response=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"evm_snapshot","params":[],"id":1}' $GANACHE_URL)
SNAPSHOT_ID=$(echo $snapshot_response | jq -r '.result')

echo "Snapshot created with ID: $SNAPSHOT_ID"