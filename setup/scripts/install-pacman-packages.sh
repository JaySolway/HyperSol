#!/bin/bash

PACKAGE_LIST=$1 #First aurgument

# Verify package list isnt empty
if [ -z "$PACKAGE_LIST" ]; then
    echo -e "${ERROR}: Missing list of packages to install\n"
    
    echo -e "RECOMMENDED: Use the main setup.sh script in the setup folder instead of running this script directly.${default}"
    echo -e ${gray}"ALTERNATIVELY: Pass a path of a file containing a list of packages to install to this script.\n"

    read -n 1 -s -p "Press any key to close..."
    exit 2
fi

# Get the output of "pacman -Qe" and store it in an array
mapfile -t PACMAN_PACKAGES < <(pacman -Qe)
PREV_INSTALLED=""
NEEDS_INSTALLED=""

# Command to remove spaces without removing newlines
CLEAN_CMD="sed 's/^[[:space:]]*//; s/[[:space:]]*$//'"

# Get packages not found in repo
NOT_FOUND=$(comm -23 <(eval "$CLEAN_CMD" < "$PACKAGE_LIST" | sort) \
                     <(pacman -Ssq | eval "$CLEAN_CMD" | sort))

# Convert NOT_FOUND to an array for easier checking
IFS=$'\n' read -rd '' -a not_found_array <<< "$NOT_FOUND"

# Loop through each line in first argument ($PACMAN_LIST_PATH)
while read -r line; do
    
    # Continue if Input line is in NOT_FOUND
    if [[ " ${not_found_array[*]} " =~ " $line " ]]; then #NOT_FOUND was converted to array above
        continue
    fi

    # Check if the line is contained in the installed packages
    if printf '%s\n' "${PACMAN_PACKAGES[@]}" | grep -q "$line"; then
        PREV_INSTALLED="$PREV_INSTALLED""$line"$'\n' # Add to already installed list
    else
        NEEDS_INSTALLED="$NEEDS_INSTALLED""$line"$'\n' # Add to needs to be installed list
    fi
done < "$PACKAGE_LIST"

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

# Packages not found in repo
if [ ! -z "$NOT_FOUND" ]; then
    echo -e "${yellow}Packages below were not found in repo or list contains duplicates:${default}"
    echo "$NOT_FOUND" 
fi

# Start Install
if [ ! -z "$NEEDS_INSTALLED" ]; then
    echo -e "\n${teal}+---- Installing Packages ----+${default}"

    # all packages must exist or none will install
    sudo pacman -S --noconfirm --needed $NEEDS_INSTALLED
    printf "\npacman Packages Installation... ${SUCCESS}\n"

else
    printf "\npacman Packages Installation... ${WARNING}\n"
    echo -e "     ${yellow}Nothing to install${default}"
fi