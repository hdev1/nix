{ pkgs, ... }:

{
  # Enable the GNOME Display Manager for graphical login.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;

  # Enable the Hyprland Wayland compositor.
  programs.hyprland.enable = true;

  # Configure OpenGL for AMD GPU. This is the correct way.
  services.xserver.videoDrivers = [ "amdgpu" ];
}
