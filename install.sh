#!/bin/bash
echo "Installing a2hoster globally"
sudo mv a2hoster.sh /usr/local/bin/a2hoster >> /dev/null
sudo mv a2hoster.func.sh /usr/local/bin/  >> /dev/null
sudo chmod 744 /usr/local/bin/a2hoster  >> /dev/null
echo "Installing complete. Check functionality by running shell with sudo a2hoster"