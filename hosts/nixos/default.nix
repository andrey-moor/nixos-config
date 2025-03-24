{ config, inputs, lib, pkgs, agenix, modulesPath, ... }:

# TODO: check these keys and add secrets if needed
let user = "andreym";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p" ]; in
{
  imports = [
    ../../modules/nixos/disk-config.nix
    ../../modules/shared
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
    kernelModules = [ ];
    kernelParams = [];
    extraModulePackages = [];
    supportedFilesystems = [ "iso9660" "vfat" "ntfs" "cifs" ];

    # prlbinfmtconfig.sh would only register binfmt when systemd-binfmt.service is enabled.
    # Following lines are added to ensure the service exists and is enabled when prlstoolsd.service runs
    binfmt = {
      # emulatedSystems = [ "x86_64-linux" ];
      registrations.RosettaLinux = {
        interpreter = "/media/psf/RosettaLinux/rosetta";

        # The required flags for binfmt are documented by Apple:
        # https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta
        magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
        mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
        fixBinary = true;
        matchCredentials = true;
        preserveArgvZero = false;

        # Remove the shell wrapper and call the runtime directly
        wrapInterpreterInShell = false;
      };
    };
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
    firewall.allowedTCPPorts = [ 5900 ];
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      extra-platforms = [ "x86_64-linux" ];
    };
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # https://github.com/NixOS/nixpkgs/issues/34603
  environment.variables = {
    GDK_SCALE = "2.0";
    GDK_DPI_SCALE = "0.2";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2.0";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "32";
  };

  # Manages keys and such
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    fish.enable = true;

  };

  services = {
    xserver = {
      enable = true;

      dpi = 220;
      # upscaleDefaultCursor = true;

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };

      displayManager = {
        defaultSession = "none+i3";

        lightdm = {
          enable = true;
          greeters.slick.enable = true;
          background = ../../modules/nixos/config/login-wallpaper.png;
        };
      };
      windowManager = {
        i3.enable = true;
      };
      # gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    };

    # https://github.com/neutrinolabs/xrdp/blob/devel/xrdp/xrdp.ini.in
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/xrdp.nix
    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.i3}/bin/i3";
      openFirewall = true;

      extraConfDirCommands = ''
        # Append VNC configuration section
        cat >> $out/xrdp.ini <<EOF
        
        [VNC]
        name=VNC
        lib=libvnc.so
        ip=127.0.0.1
        port=5900
        xserverbpp=24
        EOF
      '';
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

    pcscd = {
      enable = true;
    };

    udev.packages = [ 
      pkgs.yubikey-personalization 
      pkgs.libu2f-host
      pkgs.gnupg
    ];
  };

  hardware = {
    parallels = {
      enable = true;
    };

    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        mesa
      ];
    };

    pulseaudio.enable = false;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    # wlr.enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      common.default = "gtk";
      i3 = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
      };
    };
  };

  services.dbus.enable = true;
  services.dbus.packages = with pkgs; [
    xdg-desktop-portal
  ];

  services.pipewire = {
    enable = false;
    alsa.enable = false;
    pulse.enable = false;
    jack.enable = false;
  };

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
        "lxd"
        "plugdev"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
      initialPassword = "nixos";

      packages = with pkgs; [
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
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # https://github.com/MatthiasBenaets/nix-config/blob/master/modules/desktops/virtualisation/x11vnc.nix
  systemd.services."x11vnc" = {
    enable = true;
    description = "VNC Server for X11";
    requires = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      # Password stored in document "passwd" at $HOME. This needs auth and link to display. Otherwise x11vnc won't detect the display
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -nopw -noxdamage -nap -many -repeat -clear_keys -capslock -xkb -forever -loop100 -auth /var/run/lightdm/root/:0 -display :0 ";
      ExecStop = "${pkgs.x11vnc}/bin/x11vnc -R stop";
    };
    wantedBy = [ "multi-user.target" ];
  };
  # passwdfile: Password in /home/{vars.user}/passwd
  # noxdamage: Quicker render (maybe not optimal)
  # nap: If no acitivity, take longer naps
  # many: Keep listening for more connections
  # repeat: X server key auto repeat
  # clear_keys: Clear modifier keys on startup and exit
  # capslock: Don't ignore capslock
  # xkb: Use xkeyboard
  # forever: Keep listening for connection after disconnect
  # loop100: Loop to restart service but wait 100ms
  # auth: X authority file location so vnc also works from display manager (lightdm)
  # display: Which display to show. Even with multiple monitors it's 0
  # clip: Only show specific monitor using xinerama<displaynumber> or pixel coordinates you can find using $ xrandr -q. Can be removed to show all.

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal         # Base portal
    xdg-desktop-portal-gtk     # GTK portal (for Ghostty)

    x11vnc
    file

    (pkgs.pkgsCross.gnu64.glibc)

    librsvg
    gdk-pixbuf.dev
    gdk-pixbuf

    yubikey-manager
    yubikey-personalization
    pcsclite                # PC/SC Lite (smart card daemon)
    pcsctools               # Tools for PC/SC
  ];

  system.stateVersion = "21.05"; # Don't change this
}
