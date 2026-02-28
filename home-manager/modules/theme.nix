{ lib, ... }:

with lib;

{
  options.theme = {
    name = mkOption {
      type = types.str;
      default = "default";
      description = "The name of the theme to use.";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "The color palette of the theme.";
    };
  };
}
