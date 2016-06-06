#!/bin/bash
echo "Installing a2hoster globally"
su
mv a2hoster.sh /usr/local/bin/a2hoster
mv a2hoster.func.sh /usr/local/bin/
echo "Installing complete. Check functionality by running shell with sudo a2hoster"