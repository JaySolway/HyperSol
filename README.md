# HyperSol
Personal Arch Linux Hyprland environment and apps configuration script, files, and assets.

## Using Configuration
Run setup.sh to start the configuration process. Use the `-f` flag to auto confirm all prompts.
Durring the setup you will be prompted to run or skip the following parts of the script

**Setup**
1. Install official packages using pacman
2. Install yay AUR helper
3. Install AUR packages
4. Hardlink configs, files, and assets located in the 'files' directory

Any part can be skipped.
when hardlinking files, if any file already exists in your local profile, they will be moved to a '$HOME/OLD-CONFIGS' instead of overwriting them.

### Purpose
The intent for this repo is for my own personel use of backing up my config and quickly reconfiguring a fresh install back to my liking.
Although this is created for my own use, any is free to make use of any part they wish.
