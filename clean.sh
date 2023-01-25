#!/bin/bash

docker-compose down -v
docker rm --force $(docker ps -l -q | grep ajna-testnet)
docker rmi $(docker images noepel/ajna-testnet -a -q) -f
docker ps -l
docker images
