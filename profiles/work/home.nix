{ config, pkgs, userSettings, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;
 
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # The configs to import
  imports = [
    (./. + "../../../user/app/terminal"+("/"+userSettings.terminal)+".nix") # My default terminal selected from flake
  ];

  programs.home-manager.enable = true;

}

