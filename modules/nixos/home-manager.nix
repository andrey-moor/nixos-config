{ config, pkgs, lib, configDir, catppuccin, ... }:

let
  user = "andreym";
  xdg_configHome  = "/home/${user}/.config";
  xdg_wallpaperHome = "/home/${user}/.wallpapers";
  shared-programs = import ../shared/home-manager.nix { inherit config configDir pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config configDir pkgs; };

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
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files // import ./files.nix { inherit user configDir pkgs; };
    stateVersion = "21.05";
    pointerCursor = {
      size = 32; # Matches your XCURSOR_SIZE
      gtk.enable = true;
      x11.enable = true;
    };
  };

  xresources.properties = {
    # "Xcursor.theme" = "Catppuccin-Mocha-Dark-Cursors";
    "Xcursor.size" = 32;
  };

  catppuccin = {
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
  };

  services = {
    # dunst = {
    #   enable = true;
    #   package = pkgs.dunst;
    #   settings = {
    #     global = {
    #       monitor = 0;
    #       follow = "mouse";
    #       border = 0;
    #       height = 400;
    #       width = 320;
    #       offset = "33x65";
    #       indicate_hidden = "yes";
    #       shrink = "no";
    #       separator_height = 0;
    #       padding = 32;
    #       horizontal_padding = 32;
    #       frame_width = 0;
    #       sort = "no";
    #       idle_threshold = 120;
    #       font = "Noto Sans";
    #       line_height = 4;
    #       markup = "full";
    #       format = "<b>%s</b>\n%b";
    #       alignment = "left";
    #       transparency = 10;
    #       show_age_threshold = 60;
    #       word_wrap = "yes";
    #       ignore_newline = "no";
    #       stack_duplicates = false;
    #       hide_duplicate_count = "yes";
    #       show_indicators = "no";
    #       icon_position = "left";
    #       icon_theme = "Adwaita-dark";
    #       sticky_history = "yes";
    #       history_length = 20;
    #       history = "ctrl+grave";
    #       browser = "google-chrome-stable";
    #       always_run_script = true;
    #       title = "Dunst";
    #       class = "Dunst";
    #       max_icon_size = 64;
    #     };
    #   };
    # };

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
