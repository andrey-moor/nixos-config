{ config, inputs, lib, pkgs, agenix, modulesPath, ... }:

# TODO: check these keys and add secrets if needed
let user = "andreym";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p" ]; in
{
  imports = [
    # Import QEMU guest profile
    # "${modulesPath}/profiles/qemu-guest.nix"

    ../../modules/nixos/disk-config.nix
    ../../modules/shared
    # agenix.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };

    # TODO: Use specialization for the kernel configuration for the VM
    initrd.availableKernelModules = [ 
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage" 
    ];
    kernelModules = [ "prl_tg" "prl_fs" ];
    kernelParams = [];
    # kernelPackages = pkgs.linuxPackages_6_6;
    extraModulePackages = [];
    supportedFilesystems = [ "iso9660" "vfat" "ntfs" "cifs" ];
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "rocinante"; # Define your hostname.
    useDHCP = false;
    # VMWare Fusion
    # interfaces.ens160.useDHCP = true;
    # Parallels
    interfaces.enp0s5.useDHCP = true;
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  environment.sessionVariables = {
    # MOZ_ENABLE_WAYLAND = "1";
    # WLR_NO_HARDWARE_CURSORS = "1";
    # XDG_SESSION_TYPE = "wayland";
    # XDG_CURRENT_DESKTOP = "sway";
    #
    # GDK_BACKEND = "wayland";
    # CLUTTER_BACKEND = "wayland";
    # SDL_VIDEODRIVER = "wayland";
};

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    fish.enable = true;
    
    sway = {
      enable = false;
      wrapperFeatures.gtk = true; # So that GTK applications use the native file picker
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        mako # notification daemon
        wofi # application launcher
      ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    };
  };

  services = {
    xserver = {
      enable = true;

      videoDrivers = [ "parallels" ];

      dpi = 220;

      desktopManager = {
        xterm.enable = false;
        gnome.enable = false; # Change this to false
        wallpaper.mode = "fill";
      };

      displayManager = {
        # defaultSession = "sway";
        defaultSession = "none+i3";

        gdm = {
          enable = true;
          wayland = true;
        };
      };
      windowManager.i3.enable = true;
    };

    # TODO: Enable Syncthing

    # Let's be able to SSH into this machine
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };
  };

  hardware = {
    parallels = {
      enable = true;
      # package = config.boot.kernelPackages.prl-tools.overrideAttrs (
      #   finalAttrs: previousAttrs: {
      #     version = "20.2.2-55879";
      #     src = previousAttrs.src.overrideAttrs {
      #       outputHash = "sha256-MgToUW9H4NWjY+yBxTqg9wZ2VDNbbDu0tIeHcGZxPkM=";
      #     };
      #   }
      # );
    };

    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        mesa.drivers
        libva
      ];
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      common.default = "*";
      sway = {
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
      };
    };
  };

  services.dbus.enable = true;
  services.dbus.packages = with pkgs; [
    xdg-desktop-portal
  ];

  # Add docker daemon
  virtualisation = {
    docker = {
      enable = true;
      logDriver = "json-file";
    };
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
        "video"
        "input"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
      initialPassword = "nixos";

      packages = with pkgs; [
        firefox
        ghostty
      ];
    };

    root = {
      openssh.authorizedKeys.keys = keys;
      initialPassword = "nixos";
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
       {
         command = "${pkgs.systemd}/bin/reboot";
         options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # Share our host filesystem
  # TODO: Use specializations for the VM (e.g. VMware)
  # fileSystems."/host" = {
  #   fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
  #   device = ".host:/";
  #   options = [
  #     "umask=22"
  #     "uid=1000"
  #     "gid=1000"
  #     "allow_other"
  #     "auto_unmount"
  #     "defaults"
  #   ];
  # };
  
# fileSystems."/media/psf" = {
#   device = "prl_fs";
#   fsType = "prl_fs";
#   options = [ "defaults" "nofail" ];
# };

  environment.systemPackages = with pkgs; [
    # Essential tools
    glxinfo                    # For checking OpenGL support
    wev  # Wayland event viewer
    wlr-randr
    wayland-utils
    
    # Wayland essentials
    wayland                    # Core Wayland libraries
    wayland-protocols          # Wayland protocols
    xwayland                   # For X11 app compatibility
    wlr-randr

    # Portals (minimal set)
    xdg-desktop-portal         # Base portal
    xdg-desktop-portal-gtk     # GTK portal (for Ghostty)
    xdg-desktop-portal-wlr # Hyprland-specific portal

    # Sway-specific tools
    swaylock
    swayidle
    wl-clipboard
    wofi
    mako
  ];

  system.stateVersion = "21.05"; # Don't change this
}
