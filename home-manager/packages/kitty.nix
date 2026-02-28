{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    settings = {
      foreground = config.theme.colors.foreground;
      background = config.theme.colors.background;
      selection_background = config.theme.colors.selection;
      cursor = config.theme.colors.cursor;

      color0 = config.theme.colors.color0;
      color1 = config.theme.colors.color1;
      color2 = config.theme.colors.color2;
      color3 = config.theme.colors.color3;
      color4 = config.theme.colors.color4;
      color5 = config.theme.colors.color5;
      color6 = config.theme.colors.color6;
      color7 = config.theme.colors.color7;
      color8 = config.theme.colors.color8;
      color9 = config.theme.colors.color9;
      color10 = config.theme.colors.color10;
      color11 = config.theme.colors.color11;
      color12 = config.theme.colors.color12;
      color13 = config.theme.colors.color13;
      color14 = config.theme.colors.color14;
      color15 = config.theme.colors.color15;
    };
  };
}
