#!/bin/bash

tag=${$1:?}

echo "Use your GitHub username and paste your GitHub token as the password."
docker login ghcr.io || exit 1

# push the package to the GitHub Container Repository
echo docker commit --change='CMD ["--db", "/app/data", "--accounts", "16", "--wallet.seed", "20070213", "--port", "8555", "--fork", "${ETH_RPC_URL}", "-v"]' ajna-testnet ghcr.io/ajna-finance/ajna-testnet:${tag} || exit 2
echo docker push ghcr.io/ajna-finance/ajna-testnet:${tag}
