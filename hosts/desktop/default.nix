{ pkgs, homeManagerConfiguration, ... }:

{
  imports = [
    # 1. Import the hardware-specific configuration for this machine.
    ./hardware-configuration.nix

    # 2. Import shared, reusable modules.
    ../../modules/common.nix
    ../../modules/graphical.nix
    ../../home-manager/odie.nix
  ];

  # --- Machine-Specific Settings ---

  networking.hostName = "steve"; # Set the hostname for this machine
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  odie.monitors = [
    "DP-2,3440x1440@120,0x0,1"
    "HDMI-A-1,2560x1440@74.78,440x-1440,1"
  ];

  system.stateVersion = "25.05"; # Or your version
}
