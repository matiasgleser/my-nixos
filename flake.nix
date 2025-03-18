{

  description = "Flake of Matias Gleser";

  outputs = inputs@{ self, ... }: 
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux";      # system arch
        hostname = "nixos";           # hostname
        profile = "personal";         # select a profile defined from my profiles directory
        timezone = "America/Argentina/Cordoba"; # Timezone to be used in clock
        locale = "es_AR.UTF-8";       # The locale used in keyboard for example
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        name = "Matias";
        username = "mati"; # username
        term = "alacritty"; # terminal emulator
        dotfilesDir = "~/.dotfiles"; # absolute path of the local repo
        # theme = "io"; # selcted theme from my themes directory (./themes/)
        wm = "hyprland"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
        # window manager type (hyprland or x11) translator
        wmType = if ((wm == "hyprland") || (wm == "plasma")) then "wayland" else "x11";
        # browser = "qutebrowser"; # Default browser; must select one from ./user/app/browser/
        # spawnBrowser = if ((browser == "qutebrowser") && (wm == "hyprland")) then "qutebrowser-hyprprofile" else (if (browser == "qutebrowser") then "qutebrowser --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag num-raster-threads=4" else browser); # Browser spawn command must be specail for qb, since it doesn't gpu accelerate by default (why?)
        # defaultRoamDir = "Personal.p"; # Default org roam directory relative to ~/Org
        # font = "JetBrainsMono Nerd Font"; # Selected font
        # fontPkg = pkgs.nerd-fonts.jetbrains-mono; # Font package
        font = "MesloLGS Nerd Font Mono"; # Selected font
        fontPkg = pkgs.nerd-fonts.jetbrains-mono; # Font package
        # font = "FiraCode Nerd Font Mono"; # Selected font
        # fontPkg = pkgs.nerd-fonts.fira-code; # Font package
      };

      
      # configure pkgs
      # use nixpkgs if work profile 
      # otherwise use patched nixos-unstable nixpkgs
      pkgs = (if ((systemSettings.profile == "work") || (systemSettings.profile == "work2"))
              then
                # pkgs-stable
                pkgs-unstable
              else
                pkgs-unstable);

      pkgs-unstable = import inputs.nixpkgs {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      pkgs-stable = import inputs.nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };


      # configure lib
      # use nixpkgs if work profile
      # otherwise use patched nixos-unstable nixpkgs
      lib = (if ((systemSettings.profile == "work") || (systemSettings.profile == "work2"))
             then
               inputs.nixpkgs-stable.lib
             else
               inputs.nixpkgs.lib);

      # use home-manager-stable if running a server (homelab or worklab profile)
      # otherwise use home-manager-unstable
      home-manager = (if ((systemSettings.profile == "work") || (systemSettings.profile == "work2"))
             then
               inputs.home-manager-stable
             else
               inputs.home-manager-unstable);


      # Accesory functions
      # Systems that can run tests:
      supportedSystems = [ "x86_64-linux" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });

    in {

      # Home manager config
      homeConfigurations = {
        mati = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix") # load home.nix from selected PROFILE
          ];
          extraSpecialArgs = {
            # pass config variables from above
            inherit userSettings;
          };
        };
      };

      # System wide config
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          system = systemSettings.system;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
            # ./configuration.nix
          ]; # load configuration.nix from selected PROFILE
          specialArgs = {
            # pass config variables from above
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit inputs;
          };
        };
      };
    };


  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-stable.url = "github:nix-community/home-manager/release-24.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

}
