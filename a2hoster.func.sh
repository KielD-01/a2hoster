#!/bin/bash

function initHostRequest(){
	echo ""
}

function showMenu(){
	menuItems="1 - Sites List; 2 - Hosts List; 3 - Root checker; 4 - Create new available VHost; 5 - Remove existing Vhost; Other - Exit;"
	IFS=$';' read -r -a menuItems <<< "$menuItems"
	menuIndex=1

	while [ $menuIndex -ne ${#menuItems[@]} ]; do
        echo ${menuIndex}") " ${menuItems[${menuIndex}-1]}
	    let menuIndex=menuIndex+1
	done

	echo  "Select item from list above : "
	read menuItemSelect

	case $menuItemSelect in
		1)	showList 0 "You have been selected Sites/Projects List" "/var/www" "3";;
		2)	showList "You have been selected Hosts List" "/etc/apache2/sites-enabled" "4";;
		3)	checkRoot "--no-exit";;
		4) 	createNewHost;;
		5)  removeHost;;
		*)	exit 0;;
	esac
	echo $'\n'
}

function wantToContinue(){

	echo "Do You want to continue ? [ 1 - Yes | Other keys - No ] :"
	read wantToContinue;
	case $wantToContinue in
	1) reset

	   showMenu;;
	*) exit;; 
	esac
}


function showList(){
	echo -e $"\r\e[34m"$1"\e[0m"
	
	index=1

	for arr in $2/*; do
		IFS=$'/' read -r -a customArray <<< "$arr"
		config=${customArray[$3]}
	echo -e "\e[96m"$index") " $config"\e[0m"
		let index=index+1
	done

    if [ -z $1 ]; then
	wantToContinue
	else
	    case $1 in
	        0) wantToContinue;
	    esac
	fi
	
}

function createNewHost(){

echo -e "\e[90mEnter Project name :\e[0m"
read projectName
echo -e "\e[13mPackage wil be ignored, if not specified\e[0m"
echo -e "\e[90mEnter package name for composer install :\e[0m"
read packageName
echo -e "\e[90mEnter DocumentRoot folder \e[0m"
echo -e "\e[90mRoot directory will be ignored if empty \e[0m"
read rootFolder
echo "Installation process has been initialized..."
echo "Please, be patient"

sudo chown $USER /etc/hosts

if [ ! -d "/var/www/" ];then
    sudo mkdir -p /var/www/
    sudo chown -R $USER /var/www/
fi

cd /var/www

if [ -z "$packageName" ]; then
    echo "Package name not specified. No downloading job."
    mkdir $projectName
else

    if grep -Fxq "$projectName" "/etc/hosts" ; then
        echo "This project already in hosts. Please, choose another name"
    else
            if [ ! -d /var/www/$projectName ]; then
                composer create-project --prefer-dist $packageName $projectName --no-interaction --no-ansi --quiet
                echo -ne '\n'
            else
                echo "Project already exists"
            fi
        fi
    fi

	cd ~

	echo "Creating new Host for $projectName"

	if [ ! -d /etc/apache2/sites-enabled/ ]; then
	   sudo mkdir -p /etc/apache2/sites-enabled/
	   sudo chown $USER /etc/apache2/sites-enabled/
	fi

	newFile="/etc/apache2/sites-enabled/"$projectName".conf"

	sudo touch $newFile
	sudo chown $USER $newFile

	{
		echo "<VirtualHost *:80>"
		echo "	ServerAdmin admin@$projectName.com"
		echo "	ServerName $projectName"
		echo "	ServerAlias www.$projectName"
		if [ -z "$rootFolder" ]; then
		echo "	DocumentRoot /var/www/$projectName"
		else
		echo "	DocumentRoot /var/www/$projectName/$rootFolder"
		fi
		echo "	ErrorLog ${APACHE_LOG_DIR}/$projectName.error.log"
		echo "  CustomLog ${APACHE_LOG_DIR}/$projectName.access.log combined"
		echo "</VirtualHost>"
	} > $newFile

	echo "Adding to hosts and processing with Apache"
	
		sudo echo "127.0.0.1	$projectName    # a2hoster - Do NOT Remove this entry" >> /etc/hosts
		sudo echo "::1	    $projectName    # a2hoster - Do NOT Remove this entry" >> /etc/hosts

	{
		a2ensite $projectName".conf"
		invoke-rc.d apache2 reload
		invoke-rc.d apache2 restart
	} &>/dev/null

    # echo "Creating DB $projectName"

    # sed -r 's/.*href="([^"]*)".*/\1/' file | RegExp for changing DB configs

    # sudo mysql -uroot -e "create database '${projectName}'"

	echo "Done! Enjoy :)"

	wantToContinue

}

function removeHost(){
    echo "Which Vhost You want to delete? Enter hostname"
    showList 1
    read hostname
    if [ -z ${hostname} ]; then
        echo "No hostname specified"
        wantToContinue
    else
    echo "Are You sure to remove vhost ${hostname}?"
    read sure
    case ${sure} in
    1) echo "Removing vhost ${hostname}"
       cd /etc/apache2/sites-enabled
       sudo rm ${hostname}.conf
       cd /etc/

        array= sed '/'${hostname}'/d' hosts
        echo ${#array[@]}
#       {
#            sed '/'${hostname}'/d' hosts
#       } > hosts
        cd /var/www
        sudo rm -r ${hostname}
       echo "VHost is removed successfully";;
    esac
    fi

    wantToContinue
}