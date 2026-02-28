{ pkgs, inputs, ... }:

{
  imports = [
    # 1. Import the hardware-specific configuration for this machine.
    ./hardware-configuration.nix

    # 2. Import shared, reusable modules.
    ../../modules/common.nix
    ../../modules/graphical.nix
  ];

  # --- Machine-Specific Settings ---
  networking.hostName = "thinkpad";
  # networking.firewall.allowedTCPPorts = [ 5000 8000 8080 8081 19000 19001 19002 17011 ];
  # networking.firewall.allowedUDPPorts = [ 17010 17012 25565 ];
  networking.firewall.enable = false;
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-635c3c78-c89c-45ce-a2da-df842f6f3626".device = "/dev/disk/by-uuid/635c3c78-c89c-45ce-a2da-df842f6f3626";

  # Configure Home Manager specifically for this laptop
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.odie = {
    imports = [ ../../home-manager/home.nix ];
    
    # Laptop-specific overrides
    odie.monitors = [
      "eDP-1,1920x1200@60,0x0,1"
      "HDMI-A-1,1920x1080@144,1920x0,1,transform,1"
    ];
  };

  system.stateVersion = "25.11"; # Or your version
}
