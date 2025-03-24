{ user, configDir, ... }:

let
  home           = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
  xdg_dataHome   = "${home}/.local/share";
  xdg_wallpaperHome = "${home}/.wallpapers";
  xdg_stateHome  = "${home}/.local/state"; in
{

  "${xdg_configHome}/i3/config".source = ../../config/i3/config;
  "${xdg_configHome}/i3/i3status".source = ../../config/i3/i3status;

  "${xdg_configHome}/ghostty/config".source = ../../config/ghostty/config;

  "${xdg_wallpaperHome}".source =  "${configDir}/wallpapers";

  "${xdg_configHome}/rofi/config.rasi".source = "${configDir}/rofi/config.rasi";
  "${xdg_configHome}/rofi/catppuccin-mocha.rasi".source = "${configDir}/rofi/catppuccin-mocha.rasi";

  "${xdg_configHome}/nvim".source = "${configDir}/nvim";

  "${xdg_configHome}/fish/config.fish".source = "${configDir}/fish/config.fish";
  "${xdg_configHome}/fish/themes/catppuccin mocha.theme".source = "${configDir}/fish/themes/catppuccin mocha.theme";

  "${xdg_configHome}/jj/config.toml".source = "${configDir}/jujutsu/config.toml";

  # "${xdg_configHome}/rofi/colors.rasi".text = builtins.readFile ./config/rofi/colors.rasi;
  # "${xdg_configHome}/rofi/confirm.rasi".text = builtins.readFile ./config/rofi/confirm.rasi;
  # "${xdg_configHome}/rofi/launcher.rasi".text = builtins.readFile ./config/rofi/launcher.rasi;
  # "${xdg_configHome}/rofi/message.rasi".text = builtins.readFile ./config/rofi/message.rasi;
  # "${xdg_configHome}/rofi/networkmenu.rasi".text = builtins.readFile ./config/rofi/networkmenu.rasi;
  # "${xdg_configHome}/rofi/powermenu.rasi".text = builtins.readFile ./config/rofi/powermenu.rasi;
  # "${xdg_configHome}/rofi/styles.rasi".text = builtins.readFile ./config/rofi/styles.rasi;

  # "${xdg_configHome}/rofi/bin/launcher.sh" = {
  #   executable = true;
  #   text = ''
  #     #!/bin/sh
  #
  #     rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launcher.rasi
  #   '';
  # };
}
