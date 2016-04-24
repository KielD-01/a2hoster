#!/bin/bash

# ROOT checker
function checkRoot(){
    if [[ $EUID -ne 0 ]]; then
       echo -e "\e[31mThis script requires ROOT/SU\e[0m" 1>&2
       echo -e "\e[93mRunning as $USER\e[0m"
       echo "You want to init Root access? [1 - Yes | 2 - No ]"

       read answer

       case $answer in
        1)	initRoot;;
        *)	echo -e "\e[31mRoot access not granted. Exit.\e[0m" 
		exit;;
       esac

       else
       echo -e "\e[92mRunning as Root User : $USER\e[0m"

	if [ $1 ]; then
		case $1 in
	        "--no-exit") showMenu;;
	        *) showMenu;;
		esac
	fi

    fi
	
}

function initRoot(){
    	sudo su
	checkRoot
}

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
		1)	showList "You have been selected Sites/Projects List" "/var/www" "3";;
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
	   checkRoot	
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

	wantToContinue	
	
}

function createNewHost(){

echo -e "\e[90mEnter Project name :\e[0m"
read projectName
echo -e "\e[13mPackage wil be ignored, if not specified\e[0m"
echo -e "\e[90mEnter package name for composer install :\e[0m"
read packageName

echo "Installation process has been initialized..."
echo "Please, be patient"

cd /var/www
if [ -z "$packageName" ]; then
    echo "Package name not specified. No downloading job."
    sudo mkdir $projectName
else
	sudo composer create-project --prefer-dist $packageName $projectName
	echo -ne '\n'
fi
	sudo chmod -R 777 $projectName"/"
	cd ~

	echo "Creating new Host for $projectName"
	newFile="/etc/apache2/sites-enabled/"$projectName".conf"
	sudo touch $newFile
	{
		echo "<VirtualHost *:80>"
		echo "	ServerAdmin admin@$projectName.com"
		echo "	ServerName $projectName"
		echo "	ServerAlias www.$projectName"
		echo "	DocumentRoot /var/www/$projectName"
		echo "	ErrorLog ${APACHE_LOG_DIR}/error.log"
		echo "  CustomLog ${APACHE_LOG_DIR}/access.log combined"
		echo "</VirtualHost>"
	} > $newFile

	echo "Adding to hosts and processing with Apache"
	
		echo "127.0.0.1	$projectName" >> /etc/hosts
	
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
    echo "Which Vhost You want to delete?"
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

       {
            sed '/'${hostname}'/d' hosts
       } > hosts

       echo "VHost is removed successfully";;
    esac
    fi

    wantToContinue
}