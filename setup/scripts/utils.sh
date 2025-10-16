#!/bin/bash

# ==============================================================================
# SCRIPT CONFIGURATION
# ==============================================================================

# Initialize flags
export auto_confirm=0

# Define the usage function
usage() 
{
    echo "Usage: $0 [OPTIONS] [FILE]"
    echo ""
    echo "A script to configure HyperSol settings."
    echo ""
    echo "OPTIONS:"
    echo "  -f, --force, --noconfirm   Bypass all interactive confirmation prompts."
    echo "  -h, --help, -?             Display this help message and exit."
    echo ""
    echo "Arguments:"
    echo "  FILE                       (Optional) Path to a configuration file. (NOT YET IMPLEMENTED"
}

# Define a function to handle unsupported arguments
unsupported_arg_error() 
{
    echo "Error: Unsupported argument '$1'" >&2
    echo "Run '$0 --help' for usage information." >&2
    exit 1
}

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

# Loop through all arguments passed to the script
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        # --- Known/Supported Flags ---
        -f|--force|--noconfirm)
            auto_confirm=1
            shift
            ;;

        # --- Help Flags ---
        -h|--help|-\?)
            usage
            exit 0 # Exit successfully after showing help
            ;;

        # --- Handle Positional/Other Arguments ---
        -*)
            # If the argument starts with a hyphen but isn't a known flag
            unsupported_arg_error "$1"
            ;;

        *)
            # This handles positional arguments that don't start with a hyphen.
            # You can handle your optional FILE argument here.
            CONFIG_FILE="$1"
            shift
            ;;
    esac
done

# ==============================================================================
# VARIABLES
# ==============================================================================

#Colors
export default='\033[0m'
export red='\033[00;31m'
export green='\033[00;32m'
export yellow='\033[00;33m'
export blue='\033[00;34m'
export purple='\033[00;35m'
export cyan='\033[00;36m'
export gray='\033[00;37m'

#Common colored text
export ERROR="${red}ERROR${default}"
export FATAL_ERROR="${red}FATAL ERROR${default}"
export WARNING="${yellow}WARNING${default}"
export INFO="${gray}INFO${default}"
export SUCCESS="${green}SUCCESS${default}"

#Header color
export HBORDER='\e[36;5;40m'
export HEADER='\e[1;34;1;40m'

# Populate the associative array (for loop)
declare -A PATH_VARS
export PATH_VARS=(
    ["PACMAN_SCRIPT_PATH"]="$SCRIPT_PATH/scripts/install-pacman-packages.sh"
    ["YAY_SCRIPT_PATH"]="$SCRIPT_PATH/scripts/install-yay.sh"
    ["AUR_SCRIPT_PATH"]="$SCRIPT_PATH/scripts/install-aur-packages.sh"
    ["LINK_CONFIGS_SCRIPT"]="$SCRIPT_PATH/scripts/link-configs.sh"
    ["PACMAN_LIST_PATH"]="$SCRIPT_PATH/packages/pacman-packages"
    ["AUR_LIST_PATH"]="$SCRIPT_PATH/packages/aur-packages"
)

# Verify if file exists and is accessible
# args: file_path
verify_file_accessibility () 
{
    # Check if an argument was provided
    if [ ! "$#" -eq 1 ]; then
        echo -e "${ERROR}: verify_file_accessibility function requires exactly 1 argument (the file path)." >&2
        return 1
    fi

    local file_path="$1"

    if [ ! -r $file_path ]; then
        ((INACCESSIBLE_FILES_COUNT++))
        echo -e " ${ERROR}"
        echo -e "     ${red}Missing or inaccessible file${default}";
        echo -e "     ${red}Unable to access file $PACMAN_SCRIPT_PATH${default}\n"; 
        return 2
    fi

    return 0
}

# Loops and verifies all files exist and are accessible
verify_all_file_accessibility () 
{
    printf "\nVerifying required files... "
    # Loop over path verifying files
    for var_name in "${!PATH_VARS[@]}"; do
        file_path="${PATH_VARS[$var_name]}"
        verify_file_accessibility "$file_path"
    done

    echo -e "${SUCCESS}\n"
}

# prompt for two choices: Yes, No
# args: prompt_message
yes_no_prompt() 
{
    # Auto Confirm and skip prompt
    if [[ "$auto_confirm" -eq 1 ]]; then
        return 0
    fi

    # Check if an argument was provided
    if [ ! "$#" -eq 1 ]; then
        echo -e "${ERROR}: yes_no_prompt function requires exactly 1 argument (prompt message)." >&2
        return 2
    fi

    local prompt_message="$1"
    local input

    while [[ true ]]; do
        echo -e "\n${cyan}$prompt_message${default} [${yellow}[Y] = Yes, [N] = Skip${default}]?"
        read -p "[Y/N]: " input
        case $input in
            [Yy]* ) 
                echo -e "\nProceeding..."
                return 0 ;;
            [Nn]* ) 
                echo -e "\n     ... ${yellow}SKIPPED${default}"
                return 1 ;;
            * ) 
                printf "\n${yellow}Invalid response.${default}\n"
                continue ;;
        esac
    done
}

# Function for three choices: Yes, No, List
# args: prompt_message, pkg_list_path
yes_no_list_prompt() 
{
    # Auto Confirm and skip prompt
    if [[ "$auto_confirm" -eq 1 ]]; then
        echo "Auto Confirming"
        return 0
    fi

    # Check if an argument was provided
    if [ ! "$#" -eq 2 ]; then
        echo -e "${ERROR}: yes_no_list_prompt function requires exactly 2 arguments (prompt_message, pkg_list_path)." >&2
        return 2
    fi

    local prompt_message="$1"
    local pkg_list_path="$2"
    local input
    
    while [[ true ]]; do
        echo -e "\n${cyan}$prompt_message${default} [${yellow}[Y] = Yes, [N] = Skip, [L] = List Packages${default}]?"
        read -p "[Y/N/L]: " input
        case $input in
            [Yy]* ) 
                echo -e "\nProceeding with the installation of packages from $pkg_list_path..."
                return 0 ;;
            [Ll]* ) 
                echo -e "\n${cyan}Packages to install:${default}"
                cat "$pkg_list_path"
                printf "\n\n"
                continue ;;
            [Nn]* ) 
                echo -e "\nInstallation... ${yellow}SKIPPED${default}"
                return 1 ;;
            * ) 
                printf "\n${yellow}Invalid response.${default}\n"
                continue ;;
        esac
    done
}