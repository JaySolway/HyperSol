#!/bin/bash

# --- Configuration ---
SOURCE_DIR=$SCRIPT_PATH/../files
DEST_DIR=$HOME
BACKUP_DIR="$HOME/OLD-CONFIGS" # <--- NEW CENTRALIZED BACKUP DIRECTORY

# Resolve absolute paths (important for symlinks)
SOURCE_DIR_ABS=$(realpath "$SOURCE_DIR")
DEST_DIR_ABS=$(realpath "$DEST_DIR")

echo "Source: $SOURCE_DIR_ABS"
echo "Dest:   $DEST_DIR_ABS"
echo "Backup: $BACKUP_DIR"
echo "----------------------------------------"

# Check if the source directory exists
if [[ ! -d "$SOURCE_DIR_ABS" ]]; then
    echo "Error: Source directory not found: $SOURCE_DIR_ABS" >&2
    exit 1
fi

# Find all files recursively, including hidden files.
find "$SOURCE_DIR_ABS" -mindepth 1 -type f -print0 | while IFS= read -r -d $'\0' SOURCE_FILE_ABS; do

    # GET RELATIVE PATH
    RELATIVE_PATH="${SOURCE_FILE_ABS#$SOURCE_DIR_ABS/}"

    # DETERMINE DESTINATION PATHS
    TARGET_LINK="$DEST_DIR_ABS/$RELATIVE_PATH"
    TARGET_DIR=$(dirname "$TARGET_LINK")
    
    # Determine the path for the backup file
    BACKUP_FILE="$BACKUP_DIR/$RELATIVE_PATH"

    echo "Processing: $RELATIVE_PATH"

    # CREATE DIRECTORIES (if they don't exist)
    if [[ ! -d "$TARGET_DIR" ]]; then
        mkdir -p "$TARGET_DIR"
        echo "  --> Created directory: $TARGET_DIR"
    fi

    # HANDLE EXISTING FILE (Centralized Backup Logic)
    if [[ -e "$TARGET_LINK" ]]; then
        
        # --- Backup Directory Setup ---
        mkdir -p "$(dirname "$BACKUP_FILE")"
        
        # Case 1: Existing item is a symlink. We just replace it.
        if [[ -L "$TARGET_LINK" ]]; then          
            echo "  --> WARNING: Existing symlink found at $TARGET_LINK. Replacing it."
            rm -f "$TARGET_LINK"

        # Case 2: Existing item is a regular file, and the content is IDENTICAL to the source.    
        elif cmp -s "$SOURCE_FILE_ABS" "$TARGET_LINK"; then        
            echo "  --> NOTE: Target file is identical to source. Removing to create hard link."          
            rm -f "$TARGET_LINK"
            
        # Case 3: Existing item is a regular file, and the content is DIFFERENT move it to the centralized backup location.    
        else       
            echo "  --> CONFLICT: Existing file/directory found with DIFFERENT content. Moving to $BACKUP_FILE"           
            mv -f "$TARGET_LINK" "$BACKUP_FILE"
        fi
    fi

    # CREATE HARD LINK: This runs for every file.
    ln "$SOURCE_FILE_ABS" "$TARGET_LINK"
    
    echo "  --> Hard linked: $(basename "$SOURCE_FILE_ABS") -> $TARGET_LINK"
    echo ""
done

echo "----------------------------------------"
echo -e "Hard linking process... ${SUCCESS}"

echo -e "\nINFO: Any existing configs, assets, or files that were different than the ones contained in the files folder for this tool were backed up."
echo "Backup Location: "$HOME"/OLD-CONFIGS"