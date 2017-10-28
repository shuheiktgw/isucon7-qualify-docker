#!/bin/bash

cd ~/isubata/webapp/python

./setup.sh

export ISUBATA_DB_HOST=app03
export ISUBATA_DB_USER=isucon
export ISUBATA_DB_PASSWORD=isucon

./venv/bin/gunicorn --workers=10 -b '127.0.0.1:5000' app:app