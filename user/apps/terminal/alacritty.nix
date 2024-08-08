{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    alacritty
  ];
  programs.alacritty.enable = true;
  programs.alacritty.settings = {

    # Window config
    window = {
      # General
      decorations = lib.mkForce "none";
      opacity = lib.mkForce 0.90;

      # Dimensions
      dimensions = {
        columns = 120;
        lines = 30;
      };

      # Padding
      padding = {
        x = 2;
        y = 2;
      };
    };

    # Font config
    font = {
      size = 11.0;
      normal.family = "FiraCode Nerd Font Mono";
      bold.family = "FiraCode Nerd Font";
      italic.family = "FiraCode Nerd Font";
    }; 

    # Colors
    colors = {
      primary = {
        background = "0x1e1e1e";  # Background color
        foreground = "0xc5c8c6";  # Foreground color
      };

      cursor.cursor = "0xc5c8c6";
      selection = {
        text = "0x1e1e1e";
        background = "0xc5c8c6";
      };

      normal = {
        black = "0x1e1e1e";
        red = "0xcc6666";
        green = "0xb5bd68";
        yellow = "0xf0c674";
        blue = "0x81a2be";
        magenta = "0xb294bb";
        cyan = "0x8abeb7";
        white = "0xc5c8c6";
      };

      bright = {
        black = "0x666666";
        red = "0xd54e53";
        green = "0xb9ca4a";
        yellow = "0xe7c547";
        blue = "0x7aa6da";
        magenta = "0xc397d8";
        cyan = "0x70c0b1";
        white = "0xffffff";
      };
    };

    cursor.style = "Beam";

  };
}
