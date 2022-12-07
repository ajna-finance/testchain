FROM ethereum/client-go

ARG ACCOUNT_PASSWORD

COPY genesis.json /tmp
COPY keystore/0x3CFD.json /root/.ethereum/keystore/0x3CFD.json

RUN echo ${ACCOUNT_PASSWORD} > /tmp/password \
	&& geth init /tmp/genesis.json \
	&& rm -f ~/.ethereum/geth/nodekey

ENTRYPOINT ["geth"]
