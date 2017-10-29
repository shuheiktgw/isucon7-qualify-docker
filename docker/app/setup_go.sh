#!/bin/bash

cd ~/isubata/webapp/go

make vet
meke

export ISUBATA_DB_HOST=app03
export ISUBATA_DB_USER=isucon
export ISUBATA_DB_PASSWORD=isucon

./isubata