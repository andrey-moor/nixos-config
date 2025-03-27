{ pkgs, ... }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [

  # Security and authentication
  yubikey-agent

  # App and package management
  home-manager

  # Testing and development tools
  # direnv

  # Microsoft
  # intune-portal

  # Text and terminal utilities
  feh # Manage wallpapers
  tree
  unixtools.ifconfig
  unixtools.netstat

  # File and system utilities
  inotify-tools # inotifywait, inotifywatch - For file system events
  # i3lock-fancy-rapid
  libnotify
  # pcmanfm # File browser
  xdg-utils

  # Other utilities
  # yad # yad-calendar is used with polybar
  # xdotool
  # google-chrome
  xclip

  # System
  glxinfo                    # For checking OpenGL support

  claude-code

  # code-cursor
  # ffmpeg
]
