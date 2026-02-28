{ pkgs, ... }:

{
  # Enable the GNOME Display Manager for graphical login.
  services.displayManager.gdm.enable = true;
  services.xserver.enable = true;

  # Enable the Hyprland Wayland compositor.
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;
  
  # Configure OpenGL for AMD GPU. This is the correct way.
  services.xserver.videoDrivers = [ "amdgpu" ];
}
