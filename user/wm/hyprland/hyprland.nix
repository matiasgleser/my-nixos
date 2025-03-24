{ inputs, config, lib, pkgs, userSettings, systemSettings, pkgs-nwg-dock-hyprland, ... }:

let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # imports = [
  #   # ("../../../user/apps/term"+("/"+userSettings.term)+".nix")
  # ];

  # Packages to install
  home.packages = with pkgs; [
    hyprland
    waybar
    wofi
    kitty
    wireplumber                       # For volume control
    brightnessctl                     # For brightness control
    playerctl                         # For media control
    hyprpaper                         # For wallpaper control
    hypridle                          # For idleness control
    hyprlock                          # For lock screen
    hyprshot                          # For screenshots with mouse
    swaynotificationcenter            # For custom notifications
    libnotify
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
        "swaync"
        "waybar & hyprpaper & hypridle"
      ];

      "$terminal" = userSettings.term;
      "$fileManager" = userSettings.fileManager;
      "$menu" = "wofi --show drun";
      "$screenshot_dir" = "~/Pictures";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      general = {
        gaps_in = 1;
        gaps_out = 5;
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
        "$mainMod, L, exec, hyprctl switchxkblayout at-translated-set-2-keyboard next"  # Toggle layout

        # Screenshots
        ", PRINT, exec, hyprshot -m output -m active -o $screenshot_dir"
        "shift, PRINT, exec, hyprshot -m region -z -o $screenshot_dir"

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
        "float, class:${userSettings.fileManager}"          # Make Dolphin float by default
        "size 800 600, class:${userSettings.fileManager}"   # Optional: Set default size
        "center, class:${userSettings.fileManager}"
        "float, class:nm-applet"
        "size 600 400, class:nm-applet"  # Optional: Set a default size
        "center, class:nm-applet"        # Optional: Center it
      ];
    };
  };

  # Waybar configuration
  # programs.waybar = {
  #   enable = true;
  #   # package = pkgs.waybar.overrideAttrs (oldAttrs: {
  #   #   postPatch = ''
  #   #     # use hyprctl to switch workspaces
  #   #     sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch focusworkspaceoncurrentmonitor " + std::to_string(id());\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
  #   #     sed -i 's/gIPC->getSocket1Reply("dispatch workspace " + std::to_string(id()));/gIPC->getSocket1Reply("dispatch focusworkspaceoncurrentmonitor " + std::to_string(id()));/g' src/modules/hyprland/workspaces.cpp
  #   #   '';
  #   #   patches = [./patches/waybarpaupdate.patch ./patches/waybarbatupdate.patch];
  #   # });
  #   settings = {
  #     mainBar = {
  #       layer = "top";
  #       position = "top";
  #       height = 35;
  #       margin = "7 7 3 7";
  #       spacing = 2;

  #       modules-left = [ "group/power" "group/battery" "group/backlight" "group/cpu" "group/memory" "group/pulseaudio" "keyboard-state" ];
  #       modules-center = [ "custom/hyprprofile" "hyprland/workspaces" ];
  #       modules-right = [ "group/time" "idle_inhibitor" "tray" ];

  #       "custom/os" = {
  #         format = " {} ";
  #         exec = ''echo ""'';
  #         interval = "once";
  #         on-click = "nwggrid-wrapper";
  #         tooltip = false;
  #       };
  #       "group/power" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           children-class = "not-power";
  #           transition-left-to-right = true;
  #         };
  #         modules = [
  #           "custom/os"
  #           "custom/hyprprofileicon"
  #           "custom/lock"
  #           "custom/quit"
  #           "custom/power"
  #           "custom/reboot"
  #         ];
  #       };
  #       "custom/quit" = {
  #         format = "󰍃";
  #         tooltip = false;
  #         on-click = "hyprctl dispatch exit";
  #       };
  #       "custom/lock" = {
  #         format = "󰍁";
  #         tooltip = false;
  #         on-click = "hyprlock";
  #       };
  #       "custom/reboot" = {
  #         format = "󰜉";
  #         tooltip = false;
  #         on-click = "reboot";
  #       };
  #       "custom/power" = {
  #         format = "󰐥";
  #         tooltip = false;
  #         on-click = "shutdown now";
  #       };
  #       "custom/hyprprofileicon" = {
  #         format = "󱙋";
  #         on-click = "hyprprofile-dmenu";
  #         tooltip = false;
  #       };
  #       "custom/hyprprofile" = {
  #         format = " {}";
  #         exec = ''cat ~/.hyprprofile'';
  #         interval = 3;
  #         on-click = "hyprprofile-dmenu";
  #       };
  #       "keyboard-state" = {
  #         numlock = true;
  #         format = "{icon}";
  #         format-icons = {
  #           locked = "󰎠 ";
  #           unlocked = "󱧓 ";
  #         };
  #       };
  #       "hyprland/workspaces" = {
  #         format = "{icon}";
  #         format-icons = {
  #           "1" = "󱚌";
  #           "2" = "󰖟";
  #           "3" = "";
  #           "4" = "󰎄";
  #           "5" = "󰋩";
  #           "6" = "";
  #           "7" = "󰄖";
  #           "8" = "󰑴";
  #           "9" = "󱎓";
  #           scratch_term = "_";
  #           scratch_ranger = "_󰴉";
  #           scratch_music = "_";
  #           scratch_btm = "_";
  #           scratch_pavucontrol = "_󰍰";
  #         };
  #         on-click = "activate";
  #         on-scroll-up = "hyprnome";
  #         on-scroll-down = "hyprnome --previous";
  #         all-outputs = false;
  #         active-only = false;
  #         ignore-workspaces = ["scratch" "-"];
  #         show-special = false;
  #       };

  #       "idle_inhibitor" = {
  #         format = "{icon}";
  #         format-icons = {
  #           activated = "󰅶";
  #           deactivated = "󰾪";
  #         };
  #       };
  #       tray = {
  #         spacing = 10;
  #       };
  #       "clock#time" = {
  #         interval = 1;
  #         format = "{:%I:%M:%S %p}";
  #         timezone = "America/Chicago";
  #         tooltip-format = ''
  #           <big>{:%Y %B}</big>
  #           <tt><small>{calendar}</small></tt>'';
  #       };
  #       "clock#date" = {
  #         interval = 1;
  #         format = "{:%a %Y-%m-%d}";
  #         timezone = "America/Chicago";
  #         tooltip-format = ''
  #           <big>{:%Y %B}</big>
  #           <tt><small>{calendar}</small></tt>'';
  #       };
  #       "group/time" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = false;
  #         };
  #         modules = [ "clock#time" "clock#date" ];
  #       };

  #       cpu = { format = "󰍛"; };
  #       "cpu#text" = { format = "{usage}%"; };
  #       "group/cpu" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = true;
  #         };
  #         modules = [ "cpu" "cpu#text" ];
  #       };

  #       memory = { format = ""; };
  #       "memory#text" = { format = "{}%"; };
  #       "group/memory" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = true;
  #         };
  #         modules = [ "memory" "memory#text" ];
  #       };

  #       backlight = {
  #         format = "{icon}";
  #         format-icons = [ "" "" "" "" "" "" "" "" "" ];
  #       };
  #       "backlight#text" = { format = "{percent}%"; };
  #       "group/backlight" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = true;
  #         };
  #         modules = [ "backlight" "backlight#text" ];
  #       };

  #       battery = {
  #         states = {
  #           good = 75;
  #           warning = 30;
  #           critical = 15;
  #         };
  #         full-at = 80;
  #         format = "<span size='15000' foreground='#33ccff'>{icon}</span>";
  #         format-charging = "<span size='15000' foreground='#33ccff'>󰂄</span>";
  #         format-plugged = "<span size='15000' foreground='#33ccff'>󰂄</span>";
  #         format-full = "<span size='15000' foreground='#33ccff'>󰁹</span>";
  #         format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
  #         interval = 10;
  #         tooltip-format = "{time}\nStatus: {powerProfile}";
  #         tooltip = true;
  #       };
  #       "battery#text" = {
  #         states = {
  #           good = 75;
  #           warning = 30;
  #           critical = 15;
  #         };
  #         full-at = 80;
  #         format = "{capacity}%";
  #       };
  #       "group/battery" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = true;
  #         };
  #         modules = [ "battery" "battery#text" ];
  #       };
  #       pulseaudio = {
  #         scroll-step = 1;
  #         format = "<span size='15000' foreground='#33ccff'>{icon}</span>";
  #         format-bluetooth = "<span size='15000' foreground='#33ccff'>{icon}</span>";
  #         format-bluetooth-muted = "<span size='15000' foreground='#33ccff'>󰸈</span>";
  #         format-muted = "<span size='15000' foreground='#33ccff'>󰸈</span>";
  #         format-source = "<span size='15000' foreground='#33ccff'></span>";
  #         format-source-muted = "<span size='15000' foreground='#33ccff'></span>";
  #         format-icons = {
  #           headphone = "";
  #           hands-free = "";
  #           headset = "";
  #           phone = "";
  #           portable = "";
  #           car = "";
  #           default = [ "" "" "" ];
  #         };
  #         on-click = "hyprctl dispatch togglespecialworkspace scratch_pavucontrol; if hyprctl clients | grep pavucontrol; then echo 'scratch_ranger respawn not needed'; else pavucontrol; fi";
  #       };
  #       "pulseaudio#text" = {
  #         scroll-step = 1;
  #         format = "{volume}%";
  #         format-bluetooth = "{volume}%";
  #         format-bluetooth-muted = "";
  #         format-muted = "";
  #         format-source = "{volume}%";
  #         format-source-muted = "";
  #         on-click = "hyprctl dispatch togglespecialworkspace scratch_pavucontrol; if hyprctl clients | grep pavucontrol; then echo 'scratch_ranger respawn not needed'; else pavucontrol; fi";
  #       };
  #       "group/pulseaudio" = {
  #         orientation = "horizontal";
  #         drawer = {
  #           transition-duration = 500;
  #           transition-left-to-right = true;
  #         };
  #         modules = [ "pulseaudio" "pulseaudio#text" ];
  #       };
  #     };
  #   };
  #   style = ''
  #     * {
  #       font-family: FontAwesome, "MesloLGS Nerd Font Mono";
  #       font-size: 18px;
  #       font-weight: normal;
  #     }

  #     window#waybar {
  #       background-color: rgba(26, 26, 26, 0.9);
  #       border-radius: 8px;
  #       color: #ffffff;
  #       transition-property: background-color;
  #       transition-duration: 0.2s;
  #     }

  #     tooltip {
  #       color: #ffffff;
  #       background-color: rgba(26, 26, 26, 0.9);
  #       border-style: solid;
  #       border-width: 3px;
  #       border-radius: 8px;
  #       border-color: #ff5555;
  #     }

  #     tooltip * {
  #       color: #ffffff;
  #       background-color: rgba(26, 26, 26, 0.0);
  #     }

  #     window > box {
  #       border-radius: 8px;
  #       opacity: 0.94;
  #     }

  #     window#waybar.hidden {
  #       opacity: 0.2;
  #     }

  #     button {
  #       border: none;
  #     }

  #     #custom-hyprprofile {
  #       color: #33ccff;
  #     }

  #     button:hover {
  #       background: inherit;
  #     }

  #     #workspaces button {
  #       padding: 0px 6px;
  #       background-color: transparent;
  #       color: #cccccc;
  #     }

  #     #workspaces button:hover {
  #       color: #ffffff;
  #     }

  #     #workspaces button.active {
  #       color: #ff5555;
  #     }

  #     #workspaces button.focused {
  #       color: #33ccff;
  #     }

  #     #workspaces button.visible {
  #       color: #ffffff;
  #     }

  #     #workspaces button.urgent {
  #       color: #ff5555;
  #     }

  #     #battery,
  #     #cpu,
  #     #memory,
  #     #disk,
  #     #temperature,
  #     #backlight,
  #     #network,
  #     #pulseaudio,
  #     #wireplumber,
  #     #custom-media,
  #     #tray,
  #     #mode,
  #     #idle_inhibitor,
  #     #scratchpad,
  #     #custom-hyprprofileicon,
  #     #custom-quit,
  #     #custom-lock,
  #     #custom-reboot,
  #     #custom-power,
  #     #mpd {
  #       padding: 0 3px;
  #       color: #ffffff;
  #       border: none;
  #       border-radius: 8px;
  #     }

  #     #custom-hyprprofileicon,
  #     #custom-quit,
  #     #custom-lock,
  #     #custom-reboot,
  #     #custom-power,
  #     #idle_inhibitor {
  #       background-color: transparent;
  #       color: #cccccc;
  #     }

  #     #custom-hyprprofileicon:hover,
  #     #custom-quit:hover,
  #     #custom-lock:hover,
  #     #custom-reboot:hover,
  #     #custom-power:hover,
  #     #idle_inhibitor:hover {
  #       color: #ffffff;
  #     }

  #     #clock, #tray, #idle_inhibitor {
  #       padding: 0 5px;
  #     }

  #     #window,
  #     #workspaces {
  #       margin: 0 6px;
  #     }

  #     .modules-left > widget:first-child > #workspaces {
  #       margin-left: 0;
  #     }

  #     .modules-right > widget:last-child > #workspaces {
  #       margin-right: 0;
  #     }

  #     #clock {
  #       color: #33ccff;
  #     }

  #     #battery {
  #       color: #33ccff;
  #     }

  #     #battery.charging, #battery.plugged {
  #       color: #33ccff;
  #     }

  #     @keyframes blink {
  #       to {
  #         background-color: #ffffff;
  #         color: #000000;
  #       }
  #     }

  #     #battery.critical:not(.charging) {
  #       background-color: #ff5555;
  #       color: #ffffff;
  #       animation-name: blink;
  #       animation-duration: 0.5s;
  #       animation-timing-function: linear;
  #       animation-iteration-count: infinite;
  #       animation-direction: alternate;
  #     }

  #     label:focus {
  #       background-color: rgba(26, 26, 26, 1.0);
  #     }

  #     #cpu {
  #       color: #33ccff;
  #     }

  #     #memory {
  #       color: #33ccff;
  #     }

  #     #disk {
  #       color: #33ccff;
  #     }

  #     #backlight {
  #       color: #33ccff;
  #     }

  #     label.numlock {
  #       color: #cccccc;
  #     }

  #     label.numlock.locked {
  #       color: #33ccff;
  #     }

  #     #pulseaudio {
  #       color: #33ccff;
  #     }

  #     #pulseaudio.muted {
  #       color: #cccccc;
  #     }

  #     #tray > .passive {
  #       -gtk-icon-effect: dim;
  #     }

  #     #tray > .needs-attention {
  #       -gtk-icon-effect: highlight;
  #     }

  #     #idle_inhibitor {
  #       color: #cccccc;
  #     }

  #     #idle_inhibitor.activated {
  #       color: #33ccff;
  #     }

  #     /* Adjust icon size for modules with Pango markup */
  #     #battery span,
  #     #pulseaudio span {
  #       font-size: 15px;
  #     }
  #   '';
  # };

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
          timezone = systemSettings.timezone;
          "tooltip-format" = "{:%Y-%m-%d %H:%M (%Z)}";
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

  # Wofi configuration
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";              # Default to application launcher mode
      width = 600;                # Match Rofi’s 600px width
      height = 400;               # Reasonable height (adjustable)
      always_parse_args = true;   # Allow custom input handling
      show_all = false;           # Only show relevant apps
      term = "alacritty";         # Terminal to use if needed
      insensitive = true;         # Case-insensitive search
      allow_images = true;        # Show icons (equivalent to Rofi’s show-icons)
    };
    style = ''
      * {
        font-family: 'CaskaydiaCove Nerd Font', monospace;
        font-size: 18px;
        background-color: rgba(26, 26, 26, 0.9);  /* Dark gray background */
        color: #ffffff;                           /* White text */
      }

      /* Window */
      window {
        margin: 0px;
        padding: 10px;
        border: 2px solid #33ccff;               /* Cyan border */
        border-radius: 8px;                      /* Rounded corners */
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
      }

      /* Inner Box */
      #inner-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
      }

      /* Outer Box */
      #outer-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
      }

      /* Scroll */
      #scroll {
        margin: 0px;
        padding: 10px;
        border: none;
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
      }

      /* Input */
      #input {
        margin: 5px 20px;
        padding: 10px;
        border: 2px solid #33ccff;               /* Cyan border */
        border-radius: 0.1em;                    /* Slightly rounded */
        color: #ffffff;                          /* White text */
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
      }

      #input image {
        border: none;
        color: #33ccff;                          /* Cyan for icons */
      }

      #input * {
        outline: 4px solid #33ccff !important;   /* Cyan outline */
      }

      /* Text */
      #text {
        margin: 5px;
        border: none;
        color: #ffffff;                          /* White text */
        background-color: transparent;
      }

      #entry {
        background-color: rgba(26, 26, 26, 0.9); /* Dark gray background */
        padding: 5px;
        border-radius: 5px;                      /* Rounded corners */
      }

      #entry arrow {
        border: none;
        color: #33ccff;                          /* Cyan arrow */
      }

      /* Selected Entry */
      #entry:selected {
        border: 0.11em solid #33ccff;            /* Cyan border */
        background-color: rgba(51, 204, 255, 0.5); /* Cyan highlight */
      }

      #entry:selected #text {
        color: #ffffff;                          /* White text for selected */
      }

      #entry:drop(active) {
        background-color: rgba(51, 204, 255, 0.5) !important; /* Cyan highlight */
      }
    '';
  };

  # Configure hyprpaper for desktop wallpaper
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "$HOME/.config/backgrounds/shaded_landscape.png"
      ];
      wallpaper = [
        ",$HOME/.config/backgrounds/shaded_landscape.png"  # Apply to all monitors
      ];
    };
  };

  # Configure hyprlock
  programs.hyprlock = {
    enable = true;
    settings = {
      # Define all colors as variables at the top
      extraConfig = ''
        $mauve = rgb(203, 166, 247)      # Accent color (Catppuccin Mauve)
        $mauveAlpha = rgba(203, 166, 247, 0.5)  # Accent with alpha
        $base = rgb(30, 30, 46)          # Background base color
        $text = rgb(205, 214, 244)       # Text color
        $textAlpha = rgba(205, 214, 244, 0.8)  # Text with alpha
        $surface0 = rgb(49, 50, 68)      # Input field background
        $red = rgb(243, 139, 168)        # Failure color
        $yellow = rgb(250, 179, 135)     # Caps lock color

        $accent = $mauve
        $accentAlpha = $mauveAlpha
        $font = JetBrainsMono Nerd Font
      '';

      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      background = [
        {
          # monitor = "";
          path = "$HOME/.config/backgrounds/shaded_landscape.png";  # Same as desktop wallpaper
          blur_passes = 2;
          # color = "$base";  # Fallback color if image fails
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:30000] echo "$(date +"%R")"'';
          color = "$text";
          font_size = 70;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"'';
          color = "$text";
          font_size = 20;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];

      image = [
        {
          monitor = "";
          path = "~/.config/backgrounds/shaded_landscape.png";
          size = 100;
          border_color = "$accent";
          position = "0, 75";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 45";
          outline_thickness = 4;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = ''󰌾 Logged in as $USER'';
          hide_input = false;
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -35";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

# programs.hyprlock = {
  #   enable = true;
  #   settings = {
  #     general = {
  #       disable_loading_bar = true;
  #       grace = 0;  # Seconds to wait before locking (grace period)
  #       no_fade_in = false;  # Ensure the lock screen appears instantly
  #       no_fade_out = true; # Ensure the input field doesn't fade out
  #     };
  #     background = [
  #       {
  #         monitor = "";  # Apply to all monitors
  #         path = "";     # No image, use solid color
  #         color = "rgb(48, 48, 48)";
  #       }
  #     ];
  #     input-field = [
  #       {
  #         monitor = "";
  #         size = "200, 30";
  #         position = "0, 0";
  #         halign = "center";
  #         valign = "center";
  #         placeholder_text = "<i>Enter Password...</i>";
  #         hide_input = false;  # Always show password input (dots, not hidden)
  #         fade_on_empty = false;  # Keep input visible even when empty
  #         fail_text = "<i>Wrong Password!</i>";  # Show error but don’t hide input

  #         outer_color = "rgb(51, 51, 51)";  # Darker blackish border (#333333)
  #         inner_color = "rgb(169, 169, 169)";  # Lighter grey background (#A9A9A9)
  #         font_color = "rgb(51, 51, 51)";  
  #         outline_thickness = 1;  # Very thin border (1px)
  #       }
  #     ];
  #   };
  # };

  # Configure hypridle to lock screen after timeout
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";  # Only run hyprlock if not already running
        before_sleep_cmd = "loginctl lock-session";  # Lock before sleep
      };
      listener = [
        {
          timeout = 300;  # 5 minutes (in seconds)
          on-timeout = "hyprlock";  # Lock screen after 5 minutes of inactivity
        }
        {
          timeout = 600;  # 10 minutes (in seconds)
          on-resume = "suspend-if-no-media";
        }
      ];
    };
  };

}





