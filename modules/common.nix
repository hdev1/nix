{ pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable flakes and the new nix command.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic user account setup.
  users.users.odie = {
    isNormalUser = true;
    description = "Odie";
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # 'wheel' for sudo
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable sound with PipeWire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };

  # This creates a security wrapper for gpu-screen-recorder to allow it
  # to use the KMS backend for high-performance recording.
  security.wrappers."gsr-kms-server" = {
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    capabilities = "cap_sys_admin+ep";
    owner = "root";
    group = "root";
  };


  # For docker
  virtualisation.docker = {
    enable = true;
  };

  programs.fish.enable = true;  

  # Core packages you always want available.
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
  ];
}
