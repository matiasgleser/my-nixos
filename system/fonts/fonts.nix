{ pkgs-stable, userSettings, ... }:

{
  # Fonts are nice to have
  fonts = {
    packages = with pkgs-stable; [
      # Fonts
      nerdfonts
      powerline
      terminus_font
      font-awesome
      noto-fonts
      noto-fonts-emoji
      # nerd-fonts.meslo
    ];

    fontconfig = {
      enable = true;
      includeUserConf = true;
    };

    fontDir = {
      enable = true;
    };
  };
}
