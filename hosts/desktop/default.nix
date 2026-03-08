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

  networking.hostName = "steve"; # Set the hostname for this machine
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.firewall.enable = false;

  # Configure Home Manager specifically for this desktop
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.odie = {
    imports = [ ../../home-manager/home.nix ];

    odie.monitors = [
      "DP-2,3440x1440@120,0x0,1"
      "HDMI-A-1,2560x1440@74.78,440x-1440,1"
    ];

    odie.hyprlandExtraConfig = ''
      workspace=1,monitor:DP-2
      workspace=2,monitor:DP-2
      workspace=3,monitor:DP-2
      workspace=4,monitor:DP-2
    '';
  };

  # Mirabox macropad listener
  systemd.user.services.macropad-listener = {
    description = "Mirabox Macropad Listener Server";
    after = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];

    enable = true;
    
    serviceConfig = {
      ExecStart = "${pkgs.nix}/bin/nix-shell -p python3 --run 'python /home/odie/code/odie-software/opendeck-akp03/mirabox/pc_listener.py'";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = "PATH=${pkgs.lib.makeBinPath [
        pkgs.wireplumber   # provides wpctl
        pkgs.coreutils
        pkgs.bash
      ]}:/run/current-system/sw/bin";
    };
  };

  system.stateVersion = "25.11"; # Or your version
}
