{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
    ./modules/theme.nix
    ./themes/dracula.nix
    ./packages/base.nix
    ./packages/kitty.nix
    ./packages/vscodium.nix
    ./packages/hyprland.nix
    ./shell.nix
  ];

  home.username = "odie";
  home.homeDirectory = "/home/odie";
  home.stateVersion = "25.11";

  # Fix for Cline (Claude Dev) browser execution
  home.file.".config/VSCodium/User/globalStorage/saoudrizwan.claude-dev/puppeteer/.chromium-browser-snapshots/chromium/linux-1550062/chrome-linux/chrome" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/profiles/per-user/odie/bin/google-chrome-stable";
    force = true;
  };

  programs.home-manager.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
