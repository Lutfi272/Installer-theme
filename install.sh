#!/bin/bash

# Pastikan script dijalankan sebagai root
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

clear

# Fungsi untuk menginstal tema
installTheme(){
    # Deklarasi warna untuk output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    RESET='\033[0m'

    echo -e "${GREEN}Installing ${YELLOW}sudo${GREEN} if not installed${RESET}"
    apt install sudo -y > /dev/null 2>&1

    cd /var/www/ > /dev/null 2>&1
    echo -e "${GREEN}Unpacking theme backup...${RESET}"
    tar -cvf Pterodactyl_Nightcore_Themebackup.tar.gz pterodactyl > /dev/null 2>&1

    echo -e "${GREEN}Installing theme...${RESET}"
    cd /var/www/pterodactyl > /dev/null 2>&1
    echo -e "${GREEN}Removing old theme if exists${RESET}"
    rm -r Pterodactyl_Nightcore_Theme > /dev/null 2>&1

    echo -e "${GREEN}Downloading the Theme${RESET}"
    git clone https://github.com/NoPro200/Pterodactyl_Nightcore_Theme.git > /dev/null 2>&1
    cd Pterodactyl_Nightcore_Theme > /dev/null 2>&1

    echo -e "${GREEN}Removing old theme resources if exists${RESET}"
    rm /var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css > /dev/null 2>&1
    rm /var/www/pterodactyl/resources/scripts/index.tsx > /dev/null 2>&1

    echo -e "${GREEN}Moving new theme files to directory${RESET}"
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx > /dev/null 2>&1
    mv Pterodactyl_Nightcore_Theme.css /var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css > /dev/null 2>&1

    cd /var/www/pterodactyl > /dev/null 2>&1

    echo -e "${GREEN}Setting up Node.js environment${RESET}"
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1
    apt update -y > /dev/null 2>&1
    apt install nodejs -y > /dev/null 2>&1

    NODE_VERSION=$(node -v)
    REQUIRED_VERSION="v16.20.2"

    if [ "$NODE_VERSION" != "$REQUIRED_VERSION" ]; then
        echo -e "${GREEN}Node.js version is not ${YELLOW}${REQUIRED_VERSION}${GREEN}. Current version: ${YELLOW}${NODE_VERSION}${RESET}"
        echo -e "${GREEN}Setting Node.js version to ${YELLOW}v16.20.2${GREEN}...${RESET}"
        sudo npm install -g n > /dev/null 2>&1
        sudo n 16 > /dev/null 2>&1
        node -v > /dev/null 2>&1
        npm -v > /dev/null 2>&1
        echo -e "${GREEN}Node.js version updated to ${YELLOW}${REQUIRED_VERSION}${RESET}"
    else
        echo -e "${GREEN}Node.js version is compatible: ${YELLOW}${NODE_VERSION}${RESET}"
    fi

    apt install npm -y > /dev/null 2>&1
    npm i -g yarn > /dev/null 2>&1
    yarn > /dev/null 2>&1

    echo -e "${GREEN}Rebuilding the panel...${RESET}"
    yarn build:production > /dev/null 2>&1
    echo -e "${GREEN}Optimizing the panel...${RESET}"
    sudo php artisan optimize:clear > /dev/null 2>&1

    echo -e "${CYAN}=====================================${RESET}"
    echo -e "${GREEN}Theme successfully installed!${RESET}"
    echo -e "${CYAN}=====================================${RESET}"
}

# Fungsi untuk konfirmasi instalasi tema
installThemeQuestion(){
    while true; do
        read -p "Are you sure that you want to install the theme [y/n]? " yn
        case $yn in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Fungsi untuk memperbaiki panel
repair(){
    bash <(curl https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/repair.sh)
}

# Fungsi untuk mengembalikan backup
restoreBackUp(){
    echo -e "${GREEN}Restoring backup...${RESET}"
    cd /var/www/ > /dev/null 2>&1
    tar -xvf Pterodactyl_Nightcore_Themebackup.tar.gz > /dev/null 2>&1
    rm Pterodactyl_Nightcore_Themebackup.tar.gz > /dev/null 2>&1

    cd /var/www/pterodactyl > /dev/null 2>&1
    yarn build:production > /dev/null 2>&1
    sudo php artisan optimize:clear > /dev/null 2>&1

    echo -e "${CYAN}=====================================${RESET}"
    echo -e "${GREEN}Backup restored successfully!${RESET}"
    echo -e "${CYAN}=====================================${RESET}"
}

# Menu utama
echo "Copyright (c) 2024 Angelillo15 and NoPro200"
echo "This program is free software: you can redistribute it and/or modify"
echo ""
echo "[1] Install theme"
echo "[2] Restore backup"
echo "[3] Repair panel (use if you have an error in the theme installation)"
echo "[4] Exit"

read -p "Please enter a number: " choice
if [ $choice == "1" ]
    then
    installThemeQuestion
fi
if [ $choice == "2" ]
    then
    restoreBackUp
fi
if [ $choice == "3" ]
    then
    repair
fi
if [ $choice == "4" ]
    then
    exit
fi