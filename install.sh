#!/bin/bash
echo "Installing a2hoster globally"
sudo cp a2hoster.sh /usr/local/bin/a2hoster >> /dev/null
sudo cp a2hoster.func.sh /usr/local/bin/  >> /dev/null

# Installing server part if not exists
sudo apt-get install apache2 composer git php php5-intl php-intl php5-mcrypt php-mcrypt php5-mysql php-mysql mysql-server-* mysql-client-* libapache2-mod-php libapache2-mod-php7.0 libapache2-mod-php5 --force-yes
sudo a2enmod rewrite

sudo service apache2 restart

# Installing composer globally


sudo chmod 766 /usr/local/bin/a2hoster  >> /dev/null
echo "Installing complete. Check functionality by running shell with sudo a2hoster"
