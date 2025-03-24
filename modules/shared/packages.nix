{ pkgs, ... }:

with pkgs; [
  # General packages for development and system management
  bash-completion
  btop
  coreutils
  killall
  neofetch
  openssh
  clang

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  # libfido2

  # apps
  # microsoft-edge
  # intune-portal
  # firefox
  # qemu

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Neovim
  tree-sitter
  python3

  # Text and terminal utilities
  htop
  jq
  ripgrep
  tree
]
