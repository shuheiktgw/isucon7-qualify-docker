#!/bin/bash

sudo cp ~/isubata/files/app/nginx.* /etc/nginx/sites-available
cd /etc/nginx/sites-enabled
sudo unlink default
sudo ln -s ../sites-available/nginx.conf

sudo /etc/init.d/nginx start