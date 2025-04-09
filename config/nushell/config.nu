$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

$env.GPG_TTY = (tty)
$env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket | str trim)

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Ensure gpg-agent is running
gpgconf --launch gpg-agent

# Theme
source catppuccin_mocha.nu

# Shell Aliases
alias ll = ls -l 
alias update = sudo nixos-rebuild switch 
alias vim = nvim 
alias v = nvim 

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
