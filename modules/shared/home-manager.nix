{ config, pkgs, lib, configDir, ... }:

let name = "Andrey Moor";
    user = "andreym";
    email = "moor.andrey@gmail.com"; in
{
  direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

  ghostty = {
    enable = true;
    settings = {};
  };

  starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${configDir}/starship/starship.toml");
  };

  rofi = {
    enable = true;
    package = pkgs.rofi;
  };

  neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      astrocore
      astrolsp
      astrotheme
      astroui

      # (nvim-treesitter.withAllGrammars)
      # Add other plugins here
    ];
    extraPackages = [
      # Add any tools you need for your Neovim setup
      # For example:
      pkgs.nodejs
      pkgs.git
      pkgs.tree-sitter
      # Add pkgs.nightly.nixd # nixlanguage servers and formatters as needed
      pkgs.nixd
      pkgs.lua-language-server # lua
      pkgs.copilot-language-server
      pkgs.prettierd
      pkgs.stylua
      pkgs.selene
      pkgs.nixd
      pkgs.black
      pkgs.ripgrep
      pkgs.nodePackages."@astrojs/language-server"
      pkgs.rust-analyzer
    ];
  };

  fish = {
    enable = true;
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  ssh = {
    enable = true;
    # includes = [
    #   (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
    #     "/home/${user}/.ssh/config_external"
    #   )
    #   (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    #     "/Users/${user}/.ssh/config_external"
    #   )
    # ];
    # matchBlocks = {
    #   "github.com" = {
    #     identitiesOnly = true;
    #     identityFile = [
    #       (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
    #         "/home/${user}/.ssh/id_github"
    #       )
    #       (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    #         "/Users/${user}/.ssh/id_github"
    #       )
    #     ];
    #   };
    # };
  };
}
