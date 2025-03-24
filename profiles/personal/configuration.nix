# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, systemSettings, userSettings, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ../../system/hardware-configuration.nix
    ../../system/bin/suspend.nix
   (../../system/wm + "/${userSettings.wm}.nix")         # My window manager selected from flake
  ];

 # Ensure nix flakes are enabled
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = systemSettings.hostname;
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = systemSettings.timezone;
  services.timesyncd.enable = true; 

  i18n.defaultLocale = systemSettings.systemLang;
  # i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;

    LC_MESSAGES = systemSettings.systemLang;
    LANG = systemSettings.systemLang;
  };

  # User account
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" ]; # "input" "dialout" "video" "render" ];
    packages = [];
    uid = 1000;
  };


  # Fonts
#   fonts = {
#     packages = with pkgs; [
#       terminus_font
#       font-awesome
#       noto-fonts
#       noto-fonts-emoji
# #       nerd-fonts.meslo
#       #(nerdfonts.override {fonts = ["Meslo"];})
#     ];
#     fontconfig = {
#       enable = true;
#       includeUserConf = true;
#     };
#     fontDir = {
#       enable = true;
#     };
#   };


  # Enable Hyprland
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # Basic X server for compatibility (optional, remove if pure Wayland is desired)
  services.xserver.enable = true;
  services.xserver.xkb.layout = "${systemSettings.primaryKbLang},${systemSettings.secondaryKbLang}";

  # Display manager (using sddm, but you could use others like gdm)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoNumlock = false;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # # User account
  # users.users.mati = {
  #   isNormalUser = true;
  #   description = "mati";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [
  #     # Hyprland-specific utilities
  #     waybar            # Status bar
  #     dunst             # Notification daemon
  #     rofi-wayland      # Application launcher
  #     hyprpaper         # Wallpaper utility
  #     swaylock          # Screen locker
  #   ];
  # };



  # Programs
  programs.firefox.enable = true;
  virtualisation.docker.enable = true;
  services.teamviewer.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    neovim
    python312Full
    python312Packages.tkinter
    zip
    unzip
    rar
    pipx
    git
    docker
    go
    gcc
    # libstdcxx5
    wget
    lunarvim
    rustup
    cargo
    # nerd-fonts.fira-code
    zoxide
    bat
    openssl
    neofetch
    pkg-config
    xclip
    gparted
    pandoc
    julia
    zoom-us
    R
    # rstudio
    brave
    hugo
    spotify
    alacritty
    kitty
    xfce.thunar
    teamviewer

    # Additional Wayland utilities
    wl-clipboard      # Clipboard management
    grim             # Screenshot tool
    slurp            # Region selection for screenshots
    # mako             # Alternative notification daemon (optional)
  ];

  # Nix settings
  system.stateVersion = "24.05";
  
}
