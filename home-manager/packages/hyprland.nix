{ config, lib, pkgs, inputs, ... }:

let
  # Generate all workspace configurations, including merged submaps
  generateWorkspacesConfig = workspaces:
    let
      # Group workspaces by their primary keybind (keybind1)
      groupedByK1 = lib.groupBy (ws: ws.keybind1) workspaces;

      # Generate keybind configurations for each group
      keybindConfigs = lib.mapAttrsToList (keybind1: wsGroup:
        let
          # Workspaces in the group that have a secondary keybind (for submaps)
          submapItems = lib.filter (ws: ws.keybind2 != null) wsGroup;
          # Workspaces in the group that DO NOT have a secondary keybind
          directItems = lib.filter (ws: ws.keybind2 == null) wsGroup;

          # Generate direct binds for workspaces without a keybind2
          directBinds = lib.concatStringsSep "\n" (map (ws:
            let
              handlerScript = "/home/odie/.config/hypr/scripts/workspace-handler.sh";
              dispatcher = if ws.app != null then "exec" else "workspace";
              params = if ws.app != null then
                  "${handlerScript} \"${wsRef ws}\" \"${ws.app}\" \"${toString ws.wmClass}\" \"${toString ws.wmTitle}\" \"${if ws.startOnSwitch then "true" else "false"}\""
                else
                  wsRef ws;
            in
            ''
              bind = $mainMod, ${keybind1}, ${dispatcher}, ${params}
              bind = $mainMod SHIFT, ${keybind1}, movetoworkspace, ${wsRef ws}
            ''
          ) directItems);

          # Generate a single submap for all workspaces in the group that have a keybind2
          submap = if submapItems != [] then
            let
              submapName = "submap_k1_${keybind1}";
              moveSubmapName = "submap_move_k1_${keybind1}";
              submapBinds = lib.concatStringsSep "\n" (map (ws:
                let
                  handlerScript = "/home/odie/.config/hypr/scripts/workspace-handler.sh";
                  dispatcher = if ws.app != null then "exec" else "workspace";
                  params = if ws.app != null then
                      "${handlerScript} \"${wsRef ws}\" \"${ws.app}\" \"${toString ws.wmClass}\" \"${toString ws.wmTitle}\" \"${if ws.startOnSwitch then "true" else "false"}\""
                    else
                      wsRef ws;
                in
                ''
                  bind = , ${ws.keybind2}, ${dispatcher}, ${params}
                  bind = , ${ws.keybind2}, submap, reset
                ''
              ) submapItems);
              moveSubmapBinds = lib.concatStringsSep "\n" (map (ws:
                ''
                  bind = , ${ws.keybind2}, movetoworkspace, ${wsRef ws}
                  bind = , ${ws.keybind2}, submap, reset
                ''
              ) submapItems);
            in
            ''
              bind = $mainMod, ${keybind1}, submap, ${submapName}
              submap = ${submapName}
              ${submapBinds}
              bind = , escape, submap, reset
              bind = , catchall, submap, reset
              submap = reset

              bind = $mainMod SHIFT, ${keybind1}, submap, ${moveSubmapName}
              submap = ${moveSubmapName}
              ${moveSubmapBinds}
              bind = , escape, submap, reset
              bind = , catchall, submap, reset
              submap = reset
            ''
          else "";
        in
        lib.concatStringsSep "\n" [ directBinds submap ]
      ) groupedByK1;

      # Map named (non-numeric) workspaces to positive numeric IDs
      # Hyprland gives named workspaces negative IDs which DMS filters out
      namedWsIds = lib.listToAttrs (lib.imap0 (i: ws: {
        name = ws.name;
        value = toString (100 + i);
      }) (lib.filter (ws: builtins.match "[0-9]+" ws.name == null) workspaces));
      wsRef = ws: namedWsIds.${ws.name} or ws.name;

      # Declare named workspaces with positive IDs and display names
      workspaceDeclarations = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: id:
        "workspace = ${id}, defaultName:${name}"
      ) namedWsIds);

      # Generate window rules and startup configs for all workspaces (these are not grouped by keybind)
      otherConfigs = lib.concatStringsSep "\n" (map (ws:
        let
          windowRuleConfig =
            if ws.wmClass != null then
              "windowrule = workspace ${wsRef ws} silent, match:class ${ws.wmClass}"
            else if ws.wmTitle != null then
              "windowrule = workspace ${wsRef ws} silent, match:title ${ws.wmTitle}"
            else
              "";
          startupConfig =
            if ws.startOnStartup then
              "exec-once = ${ws.app}"
            else
              "";
        in
        ''
          # Workspace: ${ws.name}
          ${startupConfig}
          ${windowRuleConfig}
        ''
      ) workspaces);

    in
    lib.concatStringsSep "\n" ([ workspaceDeclarations otherConfigs ] ++ keybindConfigs);

  # Generate the final extra configuration string
  workspacesExtraConfig = generateWorkspacesConfig config.odie.workspaces;
in
{
  # --- Define Custom Options ---
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

  options.odie.pwaIds = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Map of PWA names to firefoxpwa site IDs, e.g. { whatsapp = \"01KKQASF...\"; }";
  };

  options.odie.workspaces = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption { type = lib.types.str; description = "Workspace name"; };
        app = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "Command to execute"; };
        wmClass = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "WM_CLASS to match"; };
        wmTitle = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "Window title to match"; };
        startOnStartup = lib.mkOption { type = lib.types.bool; default = false; description = "Start on startup"; };
        startOnSwitch = lib.mkOption { type = lib.types.bool; default = true; description = "Start on switch if not running"; };
        moveOnSwitch = lib.mkOption { type = lib.types.bool; default = true; description = "Move window on switch (not implemented, but for future)"; };
        keybind1 = lib.mkOption { type = lib.types.str; description = "First keybind"; };
        keybind2 = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "Second keybind for submap"; };
      };
    });
    default = [];
    description = "A list of fixed workspaces with apps and keybindings.";
  };

  config = {
    # --- Workspace Configuration ---
    odie.workspaces = [
      # General Workspaces
      { name = "1"; keybind1 = "1"; }
      { name = "2"; keybind1 = "2"; }
      { name = "3"; keybind1 = "3"; }
      { name = "4"; keybind1 = "4"; }
      { name = "5"; keybind1 = "5"; }
      { name = "6"; keybind1 = "6"; }
      { name = "7"; keybind1 = "7"; }
      { name = "8"; keybind1 = "8"; }

      # Code Workspaces
      { name = "code/sf"; app = "kitty --class code-sf -e zellij attach --create --force-run-commands strategyframe"; wmClass = "code-sf"; keybind1 = "C"; keybind2 = "S"; }
      { name = "code/kyl"; app = "kitty --class code-kyl -e zellij attach --create --force-run-commands kylimmo"; wmClass = "code-kyl"; keybind1 = "C"; keybind2 = "K"; }
      { name = "code/kitch"; app = "kitty --class code-kitch -e zellij attach --create --force-run-commands kitchr"; wmClass = "code-kitch"; keybind1 = "C"; keybind2 = "R"; }

      # App Workspaces
      { name = "slack"; app = "slack"; wmClass = "Slack"; keybind1 = "S"; keybind2 = "S"; }
      { name = "discord"; app = "vesktop"; wmClass = "vesktop"; keybind1 = "S"; keybind2 = "D"; }
      { name = "whatsapp"; app = "firefoxpwa site launch ${config.odie.pwaIds.whatsapp}"; wmClass = "FFPWA-${config.odie.pwaIds.whatsapp}"; keybind1 = "S"; keybind2 = "W"; }
      { name = "music"; app = "firefoxpwa site launch ${config.odie.pwaIds.music}"; wmClass = "FFPWA-${config.odie.pwaIds.music}"; keybind1 = "M"; }
      { name = "openwebui"; app = "firefoxpwa site launch ${config.odie.pwaIds.openwebui}"; wmClass = "FFPWA-${config.odie.pwaIds.openwebui}"; keybind1 = "W"; }
      { name = "obsidian"; app = "obsidian"; wmClass = "obsidian"; keybind1 = "O"; }
      { name = "thunderbird"; app = "thunderbird"; wmClass = "thunderbird"; keybind1 = "E"; startOnStartup = true; }
    ];

    home.file.".config/hypr/scripts/workspace-handler.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        WORKSPACE_REF="$1"
        APP_CMD="$2"
        WM_CLASS="$3"
        WM_TITLE="$4"
        START_ON_SWITCH="$5"

        # Switch to the target workspace
        hyprctl dispatch workspace "$WORKSPACE_REF"

        # If startOnSwitch is true, check if the app is running and start it if not.
        if [ "$START_ON_SWITCH" = "true" ]; then
          # Check if a client with the specified wmClass or wmTitle already exists.
          client_exists=$(hyprctl clients -j | jq --arg class "$WM_CLASS" --arg title "$WM_TITLE" \
            'any(.[]; if $class != "null" and $class != "" then .class == $class else .title == $title end)')

          if [ "$client_exists" != "true" ]; then
            hyprctl dispatch exec "[workspace $WORKSPACE_REF silent] $APP_CMD"
          fi
        fi
      '';
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      extraConfig = workspacesExtraConfig + "\n" + (if config.odie.hyprlandExtraConfig != null then config.odie.hyprlandExtraConfig else "");
      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";

        env = [ "XCURSOR_SIZE,24" "HYPRCURSOR_SIZE,24" "HYPRCURSOR_THEME,rose-pine-hyprcursor" ];

        # Autostart
        exec-once = [ "sunsetr" "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          scroll_factor = 1.0;
          emulate_discrete_scroll = 0;
          touchpad = {
            natural_scroll = true;
          };
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
      windowrule =  [
        "float on, match:class dropdown-term"
        "size 75% 75%, match:class dropdown-term"
        "move 30 50, match:class dropdown-term"
        "dim_around on, match:class dropdown-term"
        "center on, match:class dropdown-term"
        ];

        # --- Conditional Monitor Configuration ---
        monitor = lib.mkIf (config.odie.monitors != null) config.odie.monitors;
      
        bind = [
            # Launchers and terminals
            "$mainMod SHIFT, T, exec, kitty"
            "$mainMod, SPACE, exec, dms ipc call spotlight toggle"
            "$mainMod, E, exec, nemo"
            "$mainMod, TAB, workspace, previous"

            # DMS Modals
            "$mainMod, V, exec, dms ipc call clipboard toggle"
            "$mainMod, Backspace, exec, dms ipc call powermenu toggle"
            "$mainMod SHIFT, A, exec, dms ipc call control-center toggle"
            "$mainMod, D, exec, dms ipc call dash toggle"
            "$mainMod, SLASH, exec, dms ipc call keybinds toggle hyprland"

            # Window management
            "$mainMod SHIFT, W, killactive,"
            "$mainMod, G, togglefloating,"
            "$mainMod, F, fullscreen,"
            "$mainMod, P, pseudo,"
            "$mainMod, J, togglesplit,"

            # Utility
            "$mainMod SHIFT, C, exec, hyprpicker -r -a"
            "$mainMod, T, exec, hdrop kitty --class dropdown-term"
            "$mainMod SHIFT, S, exec, dms screenshot --no-file"

            # Move focus
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"
          ];

        bindel = [
            # Media and Brightness
            ", XF86AudioRaiseVolume, exec, dms ipc call audio increment"
            ", XF86AudioLowerVolume, exec, dms ipc call audio decrement"
            ", XF86AudioMute, exec, dms ipc call audio mute"
            ", XF86MonBrightnessUp, exec, dms ipc call brightness increment 5"
            ", XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5"
        ];

          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        
        };
    };
    

    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;             # Systemd service for auto-start
        restartIfChanged = true;   # Auto-restart dms.service when dankMaterialShell changes
      };
      
      dgop.package = inputs.dgop.packages.${pkgs.system}.default;
      
      # Core features
      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableVPN = true;                  # VPN management widget
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
      enableClipboardPaste = true;       # Pasting items from the clipboard (wtype)
    };
  };
}
