{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    
    profiles.default = {
        extensions = with pkgs.vscode-extensions; [
            ms-python.python
            saoudrizwan.claude-dev            
        ];

        userSettings = {
            "cline.chromeExecutablePath" = "/etc/profiles/per-user/odie/bin/google-chrome-stable";
            "workbench.colorCustomizations" = {
                # Base colors
                "focusBorder" = config.theme.colors.purple;
                "foreground" = config.theme.colors.foreground;
                "widget.shadow" = config.theme.colors.color0;
                "selection.background" = config.theme.colors.selection;
                "descriptionForeground" = config.theme.colors.foreground;
                "errorForeground" = config.theme.colors.red;
                "icon.foreground" = config.theme.colors.cyan;

                # Buttons & Inputs
                "button.background" = config.theme.colors.purple;
                "button.foreground" = config.theme.colors.background;
                "button.hoverBackground" = config.theme.colors.pink;
                "input.background" = config.theme.colors.color0;
                "input.foreground" = config.theme.colors.foreground;
                "input.border" = config.theme.colors.selection;
                "inputOption.activeBorder" = config.theme.colors.purple;
                "badge.background" = config.theme.colors.pink;
                "badge.foreground" = config.theme.colors.background;
                "progressBar.background" = config.theme.colors.purple;
                "dropdown.background" = config.theme.colors.color0;
                "dropdown.foreground" = config.theme.colors.foreground;
                "dropdown.border" = config.theme.colors.selection;

                # Lists
                "list.activeSelectionBackground" = config.theme.colors.selection;
                "list.activeSelectionForeground" = config.theme.colors.foreground;
                "list.hoverBackground" = config.theme.colors.color0;
                "list.highlightForeground" = config.theme.colors.orange;

                # Editor Group & Tabs
                "editorGroup.border" = config.theme.colors.selection;
                "editorGroupHeader.tabsBackground" = config.theme.colors.background;
                "tab.activeBackground" = config.theme.colors.background;
                "tab.activeForeground" = config.theme.colors.foreground;
                "tab.border" = config.theme.colors.selection;
                "tab.inactiveBackground" = config.theme.colors.color0;
                "tab.inactiveForeground" = config.theme.colors.comment;
                "tab.activeBorderTop" = config.theme.colors.purple;

                # Editor
                "editor.background" = config.theme.colors.background;
                "editor.foreground" = config.theme.colors.foreground;
                "editorCursor.foreground" = config.theme.colors.cursor;
                "editor.selectionBackground" = config.theme.colors.selection;
                "editor.lineHighlightBorder" = config.theme.colors.selection;
                "editorWidget.background" = config.theme.colors.color0;
                "editorWidget.border" = config.theme.colors.selection;

                # Activity Bar
                "activityBar.background" = config.theme.colors.color0;
                "activityBar.foreground" = config.theme.colors.foreground;
                "activityBarBadge.background" = config.theme.colors.pink;
                "activityBarBadge.foreground" = config.theme.colors.background;
                "activityBar.activeBorder" = config.theme.colors.purple;
                "activityBar.inactiveForeground" = config.theme.colors.comment;

                # Sidebar
                "sideBar.background" = config.theme.colors.background;
                "sideBar.foreground" = config.theme.colors.foreground;
                "sideBar.border" = config.theme.colors.selection;
                "sideBarTitle.foreground" = config.theme.colors.foreground;
                "sideBarSectionHeader.background" = config.theme.colors.selection;
                "sideBarSectionHeader.foreground" = config.theme.colors.foreground;

                # Status Bar
                "statusBar.background" = config.theme.colors.purple;
                "statusBar.foreground" = config.theme.colors.background;
                "statusBar.noFolderBackground" = config.theme.colors.purple;
                "statusBar.debuggingBackground" = config.theme.colors.red;

                # Terminal
                "terminal.background" = config.theme.colors.background;
                "terminal.foreground" = config.theme.colors.foreground;
                "terminalCursor.foreground" = config.theme.colors.cursor;
                "terminal.ansiBlack" = config.theme.colors.color0;
                "terminal.ansiRed" = config.theme.colors.color1;
                "terminal.ansiGreen" = config.theme.colors.color2;
                "terminal.ansiYellow" = config.theme.colors.color3;
                "terminal.ansiBlue" = config.theme.colors.color4;
                "terminal.ansiMagenta" = config.theme.colors.color5;
                "terminal.ansiCyan" = config.theme.colors.color6;
                "terminal.ansiWhite" = config.theme.colors.color7;
                "terminal.ansiBrightBlack" = config.theme.colors.color8;
                "terminal.ansiBrightRed" = config.theme.colors.color9;
                "terminal.ansiBrightGreen" = config.theme.colors.color10;
                "terminal.ansiBrightYellow" = config.theme.colors.color11;
                "terminal.ansiBrightBlue" = config.theme.colors.color12;
                "terminal.ansiBrightMagenta" = config.theme.colors.color13;
                "terminal.ansiBrightCyan" = config.theme.colors.color14;
                "terminal.ansiBrightWhite" = config.theme.colors.color15;
            };
        };
    };
  };
}
