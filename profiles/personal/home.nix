{ config, pkgs, pkgs-stable, pkgs-kdenlive, userSettings, ... }:

{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;
 
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "22.11"; 
  
  # The configs to import
  imports = [
    
    (./. + "../../../user/apps/term"+("/"+userSettings.term)+".nix") # My default terminal selected from flake
    (./. + "../../../user/wm"+("/"+userSettings.wm+"/"+userSettings.wm)+".nix") # My window manager selected from flake
    (./. + "../../../user/apps/file-manager"+("/"+userSettings.fileManager)+".nix") # My file manager selected from flake
    ../../user/apps/git/git.nix # My git config

  ];

  # Packages to use
  home.packages = [
    userSettings.fontPkg          # Install the font package specified in userSettings    

  ];

}

