{ inputs, config, lib, pkgs, userSettings, systemSettings, pkgs-nwg-dock-hyprland, ... }:

let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ../../../user/apps/term/alacritty.nix
  ];

  # Packages to install
  home.packages = with pkgs; [
    hyprland
    waybar
    rofi
    kitty
    xfce.thunar
    kdePackages.dolphin
    wireplumber                       # For volume control
    brightnessctl                     # For brightness control
    playerctl                         # For media control
    hyprpaper                         # For wallpaper control
    gnome-system-monitor              # For RAM/CPU monitoring
    networkmanagerapplet              # For network management GUI
    pavucontrol                       # For volume control GUI
  ];

  # Hyprland configuration (unchanged except for floating rule)
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      monitor = "eDP-1, 1920x1080@60, 0x0, 1";

      exec-once = [
        # "MOZ_ENABLE_WAYLAND=1 firefox"
        "chromium --ozone-platform-hint=auto"
        "waybar"
      ];

      "$terminal" = "alacritty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi -show drun";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      general = {
        gaps_in = 1;
        gaps_out = 10;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "${systemSettings.primaryKbLang},${systemSettings.secondaryKbLang}";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"

        # Language switching
        # "$mainMod, L, exec, hyprctl switchxkblayout ${systemSettings.primaryKbLang} ${systemSettings.secondaryKbLang}"
        "$mainMod, L, exec, hyprctl switchxkblayout at-translated-set-2-keyboard next"  # Toggle layout

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

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

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];

      # Make nm-applet float when opened
      windowrulev2 = [
        "float, class:nm-applet"
        "size 600 400, class:nm-applet"  # Optional: Set a default size
        "center, class:nm-applet"        # Optional: Center it
      ];
    };
  };

    # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        # modules-center = [ "hyprland/window" ];
        modules-center = [ "custom/window" ];       # Custom display of app name
        modules-right = [ "memory" "custom/separator" "cpu" "custom/separator" "network" "custom/separator" "pulseaudio" "custom/separator" "clock" "custom/separator" "battery" ];

        "hyprland/workspaces" = {
          format = "{id}";
          "on-click" = "activate";
          "all-outputs" = true;
          "persistent_workspaces" = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
          };
        };

        "custom/separator" = {
          format = "|";
          interval = "once";  # Static, no updates needed
          tooltip = false;    # No tooltip for separator
        };

        "custom/window" = {
          format = "{}";  # Display the output of the script
          interval = 1;   # Update every second
          exec = pkgs.writeShellScript "window-name" ''
            #!/bin/sh
            # Get the active window info from hyprctl
            WINDOW=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.class')
          
            # Map window class to simplified name
            case "$WINDOW" in
              "brave-browser") echo "Brave" ;;
              "firefox") echo "Firefox" ;;
              "chromium") echo "Chromium" ;;
              null) echo "" ;;
              *) echo "$WINDOW" ;;  # Fallback to class name if not a browser
            esac
          '';
          tooltip = false;  # Optional: disable tooltip if not needed
        };

        memory = {
          format = "RAM: {}%";
          interval = 2;
          "on-click" = "gnome-system-monitor";
          tooltip = true;
          "tooltip-format" = "Memory usage: {used:0.1f}G / {total:0.1f}G";
        };

        cpu = {
          format = "CPU: {usage}%";
          interval = 2;
          "on-click" = "gnome-system-monitor";
          tooltip = true;
          "tooltip-format" = "CPU usage: {usage}%";
        };

        network = {
          format-wifi = "📶";
          # format-wifi = "📶 {essid}";
          format-ethernet = "📶";
          # format-ethernet = "📶 {ipaddr}";
          format-disconnected = "🔌";
          interval = 5;
          "on-click" = "hyprctl dispatch exec 'nm-applet' && hyprctl dispatch togglefloating class:nm-applet";
          tooltip = true;
          "tooltip-format-wifi" = "{essid} - {bandwidthDownBits} ↓ / {bandwidthUpBits} ↑";
          "tooltip-format-ethernet" = "{ifname}: {ipaddr} - {bandwidthDownBits} ↓ / {bandwidthUpBits} ↑";
          "tooltip-format-disconnected" = "Disconnected";
        };

        pulseaudio = {
          format = "VOL: {volume}% {icon}";
          "format-muted" = "VOL: Muted {icon}";
          "format-icons" = {
            default = [ "🔈" "🔉" "🔊" ];
          };
          "on-click" = "pavucontrol";
          tooltip = true;
          "tooltip-format" = "Volume: {volume}%";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip = true;
          "tooltip-format" = "{:%Y-%m-%d %H:%M}";
        };

        battery = {
          format = "{capacity}% {icon}";
          "format-icons" = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          tooltip = true;
          "tooltip-format" = "Battery: {capacity}%";
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 10px;
        font-family: monospace;
        font-size: 14px;
        margin: 0;  /* Reset default margins */
      }

      window#waybar {
        background: rgba(26, 26, 26, 0.9);
        color: #ffffff;
        border-bottom: 2px solid rgba(51, 204, 255, 0.5);
      }

      #workspaces button {
        padding: 0 10px;
        color: #ffffff;
        background: transparent;
      }

      #workspaces button.active {
        background: rgba(51, 204, 255, 0.5);
        border-bottom: 2px solid #33ccff;
      }

      #window {
        padding: 0 10px;
      }

      /* Right-side modules with no padding on sides adjacent to separators */
      #memory, #cpu, #network, #pulseaudio, #clock, #battery {
        padding: 3;           /* Remove horizontal padding */
        color: #ffffff;       /* White text */
        background: transparent;  /* Transparent background */
      }

      /* Hover effect */
      #memory:hover, #cpu:hover, #network:hover, #pulseaudio:hover, #clock:hover, #battery:hover {
        background: rgba(51, 204, 255, 0.5); /* Cyan hover effect */
        border-bottom: 2px solid #33ccff;    /* Cyan border on hover */
      }

      /* Separator styling with spacing between separators */
      #custom-separator {
        color: #33ccff;       /* Matches hover border */
        padding: 0 1px;      /* Adds 10px spacing on each side */
      }
    '';
  };

  # Rofi configuration
  programs.rofi = {
    enable = true;
    # package = pkgs.rofi.override { plugins = [ pkgs.rofi-calc ]; };  # Include rofi-calc plugin
    # extraConfig = {
    #   modi = "drun,calc";              # Enable drun and calc modes
    #   font = "monospace 14";
    #   show-icons = true;
    #   kb-row-up = "Up,Control+p";      # Scroll up with Up arrow or Ctrl+p
    #   kb-row-down = "Down,Control+n";  # Scroll down with Down arrow or Ctrl+n
    #   kb-accept-entry = "Return";      # Accept selection with Enter
    # };

    theme = {
      configuration = {
        modi = "drun";
        font = "monospace 14";
        "show-icons" = true;
      };

      "*" = {
        "background-color" = "rgba(26, 26, 26, 0.9)";  # Dark gray background
        "text-color" = "#ffffff";                      # White text for readability
        "border-color" = "#33ccff";                    # Cyan borders to match Wayland tabs
      };

      window = {
        transparency = "real";
        border = 2;                                    # 2px border
        "border-color" = "#33ccff";                    # Cyan border matching Wayland tabs
        "border-radius" = "10px";                      # Rounded corners like Waybar
        width = "600px";
      };

      entry = {
        "background-color" = "rgba(26, 26, 26, 0.9)";  # Dark background for consistency
        padding = "10px";
        "text-color" = "#ffffff";                      # White text
        "border" = "2px";                              # Add a 2px border
        "border-color" = "#33ccff";                    # Cyan border for emphasis
      };

      element = {
        "border-radius" = "5px";
        padding = "5px";
        "background-color" = "rgba(26, 26, 26, 0.9)";  # Dark background
        "text-color" = "#ffffff";                      # White text
      };

      "element selected" = {
        "background-color" = "rgba(51, 204, 255, 0.5)";  # Cyan highlight matching Waybar
        "text-color" = "#ffffff";                        # White text for readability
        "border" = "2px";                                # 2px border for prominence
        "border-color" = "#33ccff";                      # Cyan border
      };

      "element-icon" = {
        padding = "0 5px 0 0";                           # Space between icon and text
        "background-color" = "transparent";
      };

      "element-text" = {
        padding = "0 0 0 5px";                           # Space from icon
        "background-color" = "transparent";
        "text-color" = "#ffffff";                        # White text
      };
    };
  };
}





