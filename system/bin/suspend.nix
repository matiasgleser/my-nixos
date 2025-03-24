{ pkgs, userSettings, ... }:

let
  # Checks if no media before suspending
  suspendIfNoMediaScript = ''
    #!/bin/sh
    if ${pkgs.playerctl}/bin/playerctl status 2>/dev/null | grep -q "Playing"; then
      echo "Media is playing, inhibiting suspend"
      exit 1
    else
      echo "No media playing, allowing suspend"
      systemctl suspend
      exit 0
    fi
  '';

in
{
  # Define the scripts as packages and place them in ~/.dotfiles/system/bin/
  environment.systemPackages = [
    (pkgs.writeScriptBin "suspend-if-no-media" suspendIfNoMediaScript)
  ];

}



