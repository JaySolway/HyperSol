#!/bin/bash

# Path of this script
SCRIPT_PATH="$(dirname "$(realpath "$0")")" #Path containing script

    # Exit if yay already installed
    if yay --version &> /dev/null; then
        printf "yay already installed, skipping\n"
        exit 
    fi

# Clone yay repo source files
git clone https://aur.archlinux.org/yay.git "$SCRIPT_PATH"/temp/yay
cd "$SCRIPT_PATH"/temp/yay

# Build and install
makepkg -si

# Remove temp files
echo "Removing temp yay files"
cd "$SCRIPT_PATH"
rm -rf "$SCRIPT_PATH"/temp

# Verify yay install
printf "\nVerifying yay install... "
if yay --version &> /dev/null; then
    printf "${SUCCESS}\n"
else
    printf "${ERROR}\n     yay failed to install\n"
fi