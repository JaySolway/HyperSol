# Commands to run in interactive sessions can go here


if status is-interactive
    alias vim='nvim' # use neovim instead of vim
 #######################################################################   
################ Using Fisher Tide plugin instead for prompt ###########
########################################################################
#    set -g fish_transient_prompt 0
#
#    function fish_prompt
#
#        # echo (prompt_pwd) # displays shortened path
#        set -l lastStatus $status # Last command status
#        #set -l user (set_color green)(whoami)@(hostnamectl hostname)(set_color normal) # using (prompt_login)
#        set -l user (prompt_login) # uses its own colors, use commented out user above for custom colors
#        set -l fullPath (set_color cyan)$PWD(set_color normal)
#        set -l currentDir (set_color cyan)(path basename $PWD)(set_color normal) #Current folder
#        set -l promptSymbol '> ' # Symbol to use at send of prompt
#
#        # Prompt status only if it's not 0
#        set -l cmdStatus
#        if test $lastStatus -ne 0
#            set cmdStatus (set_color red) "[$lastStatus]" (set_color normal)
#        end
#
#        #echo 
#        #echo $fullPath
#        #string join '' -- $currentDir $cmdStatus $promptSymbol
#        set -l prompt \n $fullPath " " (prompt_login) \n $currentDir $cmdStatus $promptSymbol
#         
#        # Rerender prompt before command is executed (Changes prompt in history)        
#        if contains -- --final-rendering $argv
#             echo -n -s ' ' # -n (dont output newline) is required for command to show in transient prompt  (-s not sure nut it removes arg spaces)
#            string join '' -- $prompt
#        else         
#            string join '' -- $prompt
#        end
#    end
#
#    function fish_right_prompt
#
#        set -l date (set_color grey)(date '+%d/%b/%Y')(set_color normal) # Current date (DD/MMM/YYYY)
#        set -l time (set_color cyan)(date '+%I:%M:%S %P')(set_color normal) # Current time (hh:MM:SS pm)
#
#        # Rerender prompt before command is executed (Changes prompt in history)        
#        if contains -- --final-rendering $argv
#            echo $date $time
#        end
#    end
end
