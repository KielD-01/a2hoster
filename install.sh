#!/bin/bash
echo "Installing a2hoster globally"
sudo cp a2hoster.sh /usr/local/bin/a2hoster >> /dev/null
sudo cp a2hoster.func.sh /usr/local/bin/  >> /dev/null

# Installing server part if not exists
sudo apt-get install apache2
sudo apt-get install php
sudo apt-get install php5-intl || sudo apt-get install php-intl
sudo apt-get install php5-mcrypt || sudo apt-get install php-mcrypt
sudo apt-get install php5-mysql || sudo apt-get install php-mysql
sudo apt-get install mysql-server-* mysql-client-*
sudo apt-get install libapache2-mod-php || libapache2-mod-php7.0 || libapache2-mod-php5
sudo a2enmod rewrite

sudo service apache2 restart

# Installing composer globally
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

sudo chmod 766 /usr/local/bin/a2hoster  >> /dev/null
echo "Installing complete. Check functionality by running shell with sudo a2hoster"
