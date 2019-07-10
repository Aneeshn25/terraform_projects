#!/bin/bash

sudo apt update
sudo apt install --yes nginx
cd /var/www/html
touch index.html
sudo echo "Hello! if you are seeing this then this is working." > index.html