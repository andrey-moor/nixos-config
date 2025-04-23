{ config, pkgs, lib, configDir, catppuccin, fenix, mcp-hub, ... }:

let
  user = "andreym";
  xdg_configHome  = "/home/${user}/.config";
  xdg_wallpaperHome = "/home/${user}/.wallpapers";
  shared-programs = import ../shared/home-manager.nix { inherit config configDir pkgs lib fenix; };
  shared-files = import ../shared/files.nix { inherit config configDir pkgs; };

  dotfiles = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config";
  # These files are generated when secrets are decrypted at build time
  gpgKeys = [
    # "/home/${user}/.ssh/pgp_github.key"
    "/home/${user}/.ssh/pgp_github.pub"
  ];
in
{
  imports = [
    catppuccin.homeManagerModules.catppuccin
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { inherit mcp-hub; };
    file = shared-files // import ./files.nix { inherit config user configDir pkgs ; };
    stateVersion = "21.05";
    pointerCursor = {
      size = 32; # Matches your XCURSOR_SIZE
      gtk.enable = true;
      x11.enable = true;
    };
  };

  xdg.configFile = {
    nvim.source = "${dotfiles}/astronvim_v5";
    astronvim_v5.source = "${dotfiles}/astronvim_v5";
  };

  # https://www.foodogsquared.one/posts/2023-03-05-combining-traditional-dotfiles-and-nixos-configurations-with-nix-flakes/#_adding_the_dotfiles_in_the_flake

  xresources.properties = {
    # "Xcursor.theme" = "Catppuccin-Mocha-Dark-Cursors";
    "Xcursor.size" = 32;
  };

  catppuccin = {
    enable = true;
    cursors = {
      enable = true;
      accent = "dark"; # This corresponds to mochaDark
    };
    gtk = {
      enable = true;
      flavor = "mocha"; # Options: latte, frappe, macchiato, mocha
      accent = "pink"; # Options: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
      tweaks = []; # Optional: "rimless", "black", "normal" (default)
      size = "compact"; # Options: "standard" or "compact"
      # Optional: Enable GNOME Shell theming
      # gnomeShellTheme = true;
    };
    nvim = {
    	enable = false;
	  };
	  vscode = {
      accent = "mauve";
      settings = {
        boldKeywords = true;
        italicComments = true;
        italicKeywords = true;
        colorOverrides = {};
        customUIColors = {};
        workbenchMode = "default";
        bracketMode = "rainbow";
        extraBordersEnabled = false;
      };
    };
  };

  services = {
    dunst = {
      enable = true;
      package = pkgs.dunst;
    };

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
      # Optional scdaemon settings
      extraConfig = ''
        allow-loopback-pinentry
      '';
      # sshKeys = [ "YOUR_KEY_ID_HERE" ]; # Replace with your GPG key ID used for SSH
    };
  };

  programs = shared-programs // { 
    gpg = {
      enable = true;

      settings = {
        # Based on https://github.com/drduh/YubiKey-Guide?tab=readme-ov-file#using-yubikey
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true;
        throw-keyids = true;
      };
      scdaemonSettings = {
        disable-ccid = true;
      };
    };

    i3status = {
      enable = true;

      general = {
        colors = true;
        color_good = "#A6E3A1";    # Green
        color_bad = "#F38BA8";     # Red
        color_degraded = "#F9E2AF"; # Yellow
        color_separator = "#89B4FA"; # Blue
      };

      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };
    };

    firefox = {
      enable = true;
      package = pkgs.librewolf;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        Preferences = {
          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
        ExtensionSettings = {
          "jid1-ZAdIEUB7XOzOJw@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
            installation_mode = "force_installed";
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "firefox-color@mozilla.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    jujutsu = {
      enable = true;
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      settings = {
        show_tabs = false;
        style = "compact";
      };
    };

    nushell = {
      enable = true;
      # configFile.source = ./config.nu;
      # shellAliases = shellAliases;
    };

    vscode = {
      enable = true;
      package = pkgs.code-cursor;  # Use Cursor AI instead of VS Code
      # Set Catppuccin as your default theme
      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";  # Or any other flavor: Latte, Frappé, Macchiato
      };
    };
  };

  # This installs my GPG signing keys for Github
  systemd.user.services.gpg-import-keys = {
    Unit = {
      Description = "Import gpg keys and set trust levels";
      After = [ "gpg-agent.socket" ];
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeScript "gpg-import-keys" ''
        #! ${pkgs.runtimeShell} -el
        # First check if the YubiKey is detected
        ${pkgs.gnupg}/bin/gpg --card-status
        
        # Import keys from local files
        for key in /mnt/public/*.asc; do
          if [ -f "$key" ]; then
            echo "Importing key: $key"
            ${pkgs.gnupg}/bin/gpg --import "$key"
            
            # Extract key ID from the imported file (this is a simplified approach)
            KEYID=$(${pkgs.gnupg}/bin/gpg --with-colons --import-options show-only --import "$key" | grep "^pub:" | cut -d: -f5)
            
            if [ ! -z "$KEYID" ]; then
              echo "Setting trust level for key: $KEYID"
              ${pkgs.gnupg}/bin/gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  trust
  5
  y
  save
  EOF
            fi
          fi
        done
      '');
    };
    
    Install = { WantedBy = [ "default.target" ]; };
  };


}
