{

  description = "Flake of Matias Gleser";

  outputs = inputs@{ self, ... }: 
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux";                           # system arch
        hostname = "nixos";                                # hostname
        profile = "personal";                              # select a profile defined from my profiles directory
        timezone = "America/Argentina/Buenos_Aires";       # Timezone to be used in clock
        locale = "es_AR.UTF-8";                            # The locale used in time settings for example
        systemLang = "en_US.UTF-8";                        # The language used in the system
        primaryKbLang = "latam";                              # The primary language used in keyboard
        secondaryKbLang = "us";                            # The secondary language used in keyboard
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        name = "Matias Gleser";
        username = "mati"; # username
        email = "matiasgleser1999@gmail.com";
        term = "alacritty"; # terminal emulator
        dotfilesDir = "~/.dotfiles"; # absolute path of the local repo
        theme = "io"; # selcted theme from my themes directory (./themes/)
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
        fileManager = "nautilus";
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
            inherit systemSettings;
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
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    
    # hyprland = {
    #   url = "github:hyprwm/Hyprland/v0.44.1?submodules=true";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprland-plugins = {
    #   type = "git";
    #   url = "https://code.hyprland.org/hyprwm/hyprland-plugins.git";
    #   rev = "4d7f0b5d8b952f31f7d2e29af22ab0a55ca5c219"; #v0.44.1
    #   inputs.hyprland.follows = "hyprland";
    # };

    # hyprlock = {
    #   type = "git";
    #   url = "https://code.hyprland.org/hyprwm/hyprlock.git";
    #   rev = "73b0fc26c0e2f6f82f9d9f5b02e660a958902763";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprgrass = {
    #   url = "github:horriblename/hyprgrass/427690aec574fec75f5b7b800ac4a0b4c8e4b1d5";
    #   inputs.hyprland.follows = "hyprland";
    # };

  };

}
