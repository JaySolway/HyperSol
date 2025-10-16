#!/bin/bash

# Get list to install from first arg
PACKAGE_LIST="$1"

# check if yay installed already  
if ! yay --version &> /dev/null; then
    printf "\n${ERROR}\n     ${red}yay not installed and is required to install AUR packages${default}\n"
    echo "\n Rerun setup to install yay"
    read -n 1 -s -p "Press any key to close..."
    exit
fi

# Verify package list isnt empty
if [ -z "$PACKAGE_LIST" ]; then
    echo -e "${ERROR}: Missing list of AUR packages to install\n"
    
    echo -e "RECOMMENDED: Use the main setup.sh script in the setup folder instead of running this script directly.${default}"
    echo -e ${gray}"ALTERNATIVELY: Pass a path of a file containing a list of AUR packages to install to this script.\n"

    read -n 1 -s -p "Press any key to close..."
    exit 2
fi

# Update AUR packages
echo Updating AUR packages...
yay -Syu --noconfirm 

# Get the output of "yay -Qe" and store it in an array
mapfile -t INSTALLED_AUR_PACKAGES < <(yay -Qe | awk '{print $1}' | sort) # awk to strip the version number

#  Clean list, Strip comments, remove blank lines, sort, and remove carriage returns.
DESIRED_PACKAGES_CLEANED=$(grep -v '^\s*#' "$PACKAGE_LIST" | sed '/^\s*$/d' | tr -d '\r' | sort)

PREV_INSTALLED=""
NEEDS_INSTALLED=""
NOT_FOUND=""

# Loop through each cleaned line using subshell method (prevents external programs from messing with loop)
while IFS= read -r line; do
    # Check if the package exists in the AUR
    RESULT=$(yay -Ssq "$line" < /dev/null 2> /dev/null | grep -w "^$line$")
    if [ -z "$RESULT" ]; then
        NOT_FOUND="$NOT_FOUND""$line"$'\n' # Add to not found list  
        continue     
    fi
    
    # Check if package already installed
    if printf '%s\n' "${INSTALLED_AUR_PACKAGES[@]}" | grep -q -w "$line"; then
        PREV_INSTALLED="$PREV_INSTALLED""$line"$'\n' # Add to already installed list
    else
        NEEDS_INSTALLED="$NEEDS_INSTALLED""$line"$'\n' # Add to needs to be installed list
    fi
    
# Process the cleaned list via a pipe (or process substitution)
done <<< "$DESIRED_PACKAGES_CLEANED"

# Packages already installed
if [ ! -z "$PREV_INSTALLED" ]; then
    echo -e "\n${cyan}Already Installed${default}:"
    echo "$PREV_INSTALLED"
fi 

# Packages to install
if [ ! -z "$NEEDS_INSTALLED" ]; then
    echo -e "${cyan}Needs to be Installed${default}:"
    echo "$NEEDS_INSTALLED" 
fi

# Packages not found in Arch User Repo (AUR)
if [ ! -z "$NOT_FOUND" ]; then
    echo -e "${yellow}Packages below were not found in the AUR or list contains duplicates:${default}"
    echo "$NOT_FOUND" 
fi

# Start Install
if [ ! -z "$NEEDS_INSTALLED" ]; then
    echo -e "\n${teal}+---- Installing AUR Packages ----+${default}"

    # method2 (notused) 2 Will install packages even if some fail
    # Loop through each line in first argument ($PACKAGE_LIST)
    #while read -r line; do
    #    sudo pacman -S --noconfirm --needed "$line"
    #done <<< "$NEEDS_INSTALLED"

    # all packages must exist or none will install
    yay -S --noconfirm --needed $NEEDS_INSTALLED

    echo -e "\nAUR Packages Install... ${SUCCESS}"

else
    echo -e "\nAUR Packages Install... ${WARNING}"
    echo -e "     ${yellow}Nothing to install${default}"
fi