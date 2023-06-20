#!/bin/bash

tag=$1
if [[ -z ${tag} ]]; then echo "please specify label (for example, rc6)" && exit 1; fi

echo "Use your GitHub username and paste your GitHub token as the password."
docker login ghcr.io || exit 2

# push the package to the GitHub Container Repository
set -x
docker commit --change='CMD ["--db", "/app/data", "--accounts", "16", "--wallet.seed", "20070213", "--port", "8555", "--fork", "${ETH_RPC_URL}", "-v"]' ajna-testnet ghcr.io/ajna-finance/ajna-testnet:${tag} || exit 3
docker push ghcr.io/ajna-finance/ajna-testnet:${tag}
