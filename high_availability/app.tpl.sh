#!/bin/bash

sudo apt update
sudo apt install --yes nginx
cd /var/www/html
touch index.html

echo "<!DOCTYPE html>" >index.html
echo "<html>" >> index.html
echo "<head>" >> index.html
echo "<meta charset="UTF-8">" >> index.html
echo "<title>Welcome</title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<center><p>-------------------------------------</p></center>" >> index.html
echo "<center><h1>Hello world</h1></center>" >> index.html
echo "<center><p>-------------------------------------</p></center>" >> index.html
echo "<center><p>Hostname--"$HOSTNAME"</p></center>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
