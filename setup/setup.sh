#!/bin/bash
export SCRIPT_PATH="$(dirname "$(realpath "$0")")"
source "$SCRIPT_PATH"/scripts/utils.sh

echo -e "${HBORDER}╔══════════════════════════════════════════════════════════════════════╗"
echo -e "║${default}${HEADER}__██╗__██╗██╗___██╗██████╗_███████╗██████╗_███████╗_██████╗_██╗_______${HBORDER}║"
echo -e "║${default}${HEADER}__██║__██║╚██╗_██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██║_______${HBORDER}║"
echo -e "║${default}${HEADER}__███████║_╚████╔╝_██████╔╝█████╗__██████╔╝███████╗██║___██║██║_______${HBORDER}║"
echo -e "║${default}${HEADER}__██╔══██║__╚██╔╝__██╔═══╝_██╔══╝__██╔══██╗╚════██║██║___██║██║_______${HBORDER}║"
echo -e "║${default}${HEADER}__██║__██║___██║___██║_____███████╗██║__██║███████║╚██████╔╝███████╗__${HBORDER}║"
echo -e "║${default}${HEADER}__╚═╝__╚═╝___╚═╝___╚═╝_____╚══════╝╚═╝__╚═╝╚══════╝_╚═════╝_╚══════╝__${HBORDER}║"
echo -e "${HBORDER}╚══════════════════════════════════════════════════════════════════════╝${default}"

echo -e "Preparing HyperSol Configurator\n"
printf "${cyan}Requesting root privileges now...\n${default}"
sudo -v


verify_all_file_accessibility

# Update system
sudo pacman -Syu

# Pacman packages installation
if yes_no_list_prompt "Install pacman packages defined in ${PATH_VARS["PACMAN_LIST_PATH"]}?" ${PATH_VARS["PACMAN_LIST_PATH"]}; then # Returns 0 if prompt confirmed
    bash "${PATH_VARS["PACMAN_SCRIPT_PATH"]}" ${PATH_VARS["PACMAN_LIST_PATH"]}
fi

# Run yay Installation 
if yes_no_prompt "Install yay AUR package helper?"; then # Returns 0 if prompt confirmed
    bash "${PATH_VARS["YAY_SCRIPT_PATH"]}"
fi

# Install AUR packages
if yes_no_list_prompt "Install AUR packages using yay defined in ${PATH_VARS["AUR_LIST_PATH"]}?" "${PATH_VARS["AUR_LIST_PATH"]}"; then # Returns 0 if prompt confirmed
    bash "${PATH_VARS["AUR_SCRIPT_PATH"]}" ${PATH_VARS["AUR_LIST_PATH"]}
fi

# Symlink configs and assets
if yes_no_prompt "Hard link configs, assets, and files in the "/File" directory?"; then # Returns 0 if prompt confirmed
    bash "${PATH_VARS["LINK_CONFIGS_SCRIPT"]}"
fi

echo -e "\n${cyan}Configuration complete${default}"