#!/bin/bash

# Color Reset
Color_Off='\033[0m'       # Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Ititialization

mainmenu () {
  echo "Press 1 to update/upgrade your system"
  echo "Press 2 to install Docker"
  echo "Press 3 to install Docker Compose"
  echo "Press q to exit the script"
  read -n 1 -p "Input Selection:" mainmenuinput
  if [ "$mainmenuinput" = "1" ]; then
            apt-get update && apt-get upgrade -y
        elif [ "$mainmenuinput" = "2" ]; then
            docker
        elif [ "$mainmenuinput" = "3" ]; then
	    install-compose
        elif [ "$mainmenuinput" = "4" ]; then
            installwebmin
        elif [ "$mainmenuinput" = "5" ]; then
            configuresambaforactivedirectory
        elif [ "$mainmenuinput" = "q" ];then
	    echo -e "\n\nBye Bye\n"
            exit

        else
            echo "You have entered an invallid selection!"
            echo "Please try again!"
            echo ""
            echo "Press any key to continue..."
            read -n 1
            clear
            mainmenu
        fi
}

apt-checker () {
  if [[ -n "$(command -v apt-get)" ]]; then
	  :
    else
      echo "This script is only for apt-get. check your OS before running the script."
      exit 1
  fi

}

root-checker () {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
  fi
}

docker () {
  echo -e "Installing Docker latest version"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  systemctl enable docker
  sleep 5

}

install-compose () {
        # check id already installed
        if [ -n "$(command -v docker-compose)" ]; then
                current_version=$(docker-compose --version|awk '{print $NF}')
                echo -e "\n\nDocker Compose is Already Installed.\nDocker Compose Version: ${current_version}"
                echo "press ctrl+c to stop."
                echo "Do nothing for upgrade."
                sleep 10
                echo "Checking for updates..."
                latest_release=$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" |grep -Po '"tag_name": "\K.*?(?=")')
                if [ ${current_version} == ${latest_release} ]; then
                        echo "Already Latest Version"
                else
                        echo -e "Installing Docker Compose Latest Version: \"${latest_release}\"."
                        curl -L https://github.com/docker/compose/releases/download/"${latest_release}"/docker-compose-"$(uname -s)"-"$(uname -m)" \
                                -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
                        echo -e "\n\nDocker Compose Installed.\n"
                fi

        fi

}


root-checker
apt-checker
while true; do
	mainmenu
done


# This executes the main menu function.
# Let the fun begin!!!! WOOT WOOT!!!!
