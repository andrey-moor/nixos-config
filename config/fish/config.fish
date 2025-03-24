#-------------------------------------------------------------------------------
# Interactive Shell Settings
#-------------------------------------------------------------------------------

if status is-interactive
    #-------------------------------------------------------------------------------
    # GPG Agent
    #-------------------------------------------------------------------------------
    
    # Set GPG TTY
    set -gx GPG_TTY (tty)
    
    # Set SSH to use GPG agent
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    
    # Ensure gpg-agent is running
    gpgconf --launch gpg-agent
    
    #-------------------------------------------------------------------------------
    # Theme 
    #-------------------------------------------------------------------------------
    
    fish_config theme choose "catppuccin mocha"
    
    #-------------------------------------------------------------------------------
    # Shell Aliases
    #-------------------------------------------------------------------------------
    
    # Add your aliases here
    alias ll "ls -l"
    alias update "sudo nixos-rebuild switch"
    alias vim "nvim"
    alias v "nvim"
    
    #-------------------------------------------------------------------------------
    # Interactive Key Bindings
    #-------------------------------------------------------------------------------
    
    fish_vi_key_bindings # Use vim key bindings
end

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

# Disable greeting
function fish_greeting
end

#-------------------------------------------------------------------------------
# Global Environment Variables
#-------------------------------------------------------------------------------

# Set environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

starship init fish | source
