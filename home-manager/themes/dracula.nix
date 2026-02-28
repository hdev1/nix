{ config, ... }:

let
  # Base
  background = "#21222c";
  foreground = "#f8f8f2";
  selection = "#44475a";
  comment = "#6272a4";
  
  # Colors
  cyan = "#8be9fd";
  green = "#50fa7b";
  orange = "#ffb86c";
  pink = "#ff79c6";
  purple = "#bd93f9";
  red = "#ff5555";
  yellow = "#f1fa8c";
in
{
  theme = {
    name = "Dracula Theme";
    colors = {
      inherit background foreground selection comment cyan green orange pink purple red yellow;
      
      cursor = foreground;

      # ANSI Colors
      color0 = "#21222c"; # Black (Host)
      color1 = red;
      color2 = green;
      color3 = yellow;
      color4 = purple;
      color5 = pink;
      color6 = cyan;
      color7 = foreground;

      color8 = comment; # Bright Black
      color9 = "#ff6e6e"; # Bright Red
      color10 = "#69ff94"; # Bright Green
      color11 = "#ffffa5"; # Bright Yellow
      color12 = "#d6acff"; # Bright Purple
      color13 = "#ff92df"; # Bright Pink
      color14 = "#a4ffff"; # Bright Cyan
      color15 = "#ffffff"; # Bright White
    };
  };
}
