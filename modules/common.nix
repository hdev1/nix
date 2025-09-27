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
