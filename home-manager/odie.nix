# /etc/nixos/home-manager/odie.nix
{ config, lib, pkgs, inputs, ... }:

{
  # --- Define a New Custom Option ---
  # This creates a variable `odie.monitors` that we can set from other files.
  options.odie.monitors = lib.mkOption {
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
    description = "A list of monitor configuration strings for Hyprland.";
  };

  options.odie.hyprlandExtraConfig = lib.mkOption {
    type = lib.types.nullOr lib.types.lines;
    default = null;
    description = "Extra configuration lines to append to hyprland.conf.";
  };

  # --- The Rest of Your Configuration ---
  config = {
    home-manager.users.odie = {
      imports = [ inputs.caelestia-shell.homeManagerModules.default ];

      home.username = "odie";
      home.homeDirectory = "/home/odie";
      home.stateVersion = "25.05";

      home.packages = with pkgs; [
        git
        vscodium
        firefox
        kitty
        inputs.hyprland-contrib.packages.${pkgs.system}.hdrop
        inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
        slack
        vesktop
        docker
        nodejs_24
        wireguard-tools
        pavucontrol
        xdg-desktop-portal-hyprland
        wireplumber
        neofetch
        hyprsunset
        sunsetr
        gnumake
        python3
        gpu-screen-recorder
      ];
      programs.fish.enable = true;
      programs.home-manager.enable = true;


      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = lib.mkIf (config.odie.hyprlandExtraConfig != null) config.odie.hyprlandExtraConfig;
        settings = {
          "$mainMod" = "SUPER";
          "$terminal" = "kitty";

          env = [ "XCURSOR_SIZE,24" "HYPRCURSOR_SIZE,24" "HYPRCURSOR_THEME,rose-pine-hyprcursor" ];

          # Autostart
          exec-once = [ "sunsetr" ];

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            scroll_factor = 1.0;
            emulate_discrete_scroll = 0;
          };

          dwindle = {
            pseudotile = "yes";
            preserve_split = "yes";
          };

          decoration = {
            rounding = 10;
            rounding_power = 2;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
            };

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur = {
                enabled = true;
                size = 3;
                passes = 1;

                vibrancy = 0.1696;
            };
        };

        # Floating terminal
        windowrulev2 =  [
          "float,class:dropdown-term"
          "size 75% 75%,class:dropdown-term"
          "move 30 50, class:dropdown-term"
          "dimaround, class:dropdown-term"
          "center, class:dropdown-term"
          ];

          # --- Conditional Monitor Configuration ---
          # This uses the new option. `lib.mkIf` ensures this section is only
          # added if `odie.monitors` has been set to a value (is not null).
          monitor = lib.mkIf (config.odie.monitors != null) config.odie.monitors;
        
          bind = [
              # Launchers and terminals
              "$mainMod SHIFT, T, exec, kitty"
              "$mainMod, SPACE, global, caelestia:launcher"
              "$mainMod SHIFT, R, exec, caelestia record -r"
              "$mainMod SHIFT, S, exec, caelestia screenshot -r"
              "$mainMod, R, exec, $menu"
              "$mainMod, C, exec, codium"
              "$mainMod, E, exec, nemo" # Note: this was bound twice, using the nemo one.

              # Window management
              "$mainMod SHIFT, W, killactive,"
              "$mainMod, G, togglefloating,"
              "$mainMod, F, fullscreen,"
              "$mainMod, P, pseudo,"
              "$mainMod, J, togglesplit,"

              # Utility
              "$mainMod SHIFT, C, exec, hyprpicker -r -a"
              "$mainMod, T, exec, hdrop kitty --class dropdown-term"

              # Move focus
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"

              # Switch workspaces
              "$mainMod, 1, workspace, 1"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"

              # Move window to workspace
              "$mainMod SHIFT, 1, movetoworkspace, 1"
              "$mainMod SHIFT, 2, movetoworkspace, 2"
              "$mainMod SHIFT, 3, movetoworkspace, 3"
              "$mainMod SHIFT, 4, movetoworkspace, 4"
              "$mainMod SHIFT, 5, movetoworkspace, 5"
              "$mainMod SHIFT, 6, movetoworkspace, 6"
              "$mainModSHIFT, 7, movetoworkspace, 7"
              "$mainMod SHIFT, 8, movetoworkspace, 8"
              "$mainMod SHIFT, 9, movetoworkspace, 9"
              "$mainMod SHIFT, 0, movetoworkspace, 10"

              # Switch to named workspaces
              "$mainMod, M, workspace, name:music"
              "$mainMod, E, workspace, name:email"
              "$mainMod, O, workspace, name:obsidian"
              "$mainMod, H, workspace, name:chat"
            ];

            bindm = [
              "$mainMod, mouse:272, movewindow"
              "$mainMod, mouse:273, resizewindow"
            ];
          
          };

      };

      programs.caelestia = {
        enable = true;
        systemd = {
          enable = true;
          target = "graphical-session.target";
          environment = [];
        };
        settings = {
          bar.status = {
            showBattery = false;
          };
          paths.wallpaperDir = "~/Images";
        };
        cli = {
          enable = true; # Also add caelestia-cli to path
          settings = {
            theme.enableGtk = false;
          };
        };
      };
    };
  };
}
