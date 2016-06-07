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
sudo apt-get install mysql-server-*

# Installing composer globally
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '070854512ef404f16bac87071a6db9fd9721da1684cd4589b1196c3faf71b9a2682e2311b36a5079825e155ac7ce150d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

sudo chmod 744 /usr/local/bin/a2hoster  >> /dev/null
echo "Installing complete. Check functionality by running shell with sudo a2hoster"