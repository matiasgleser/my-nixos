{

  description = "Flake of Matias Gleser";

  outputs = inputs@{ self, ... }: 
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "nixos"; # hostname
        profile = "work"; # select a profile defined from my profiles directory
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "mati"; # username
        terminal = "alacritty"; # terminal em
      };

      
      # configure pkgs
      # use nixpkgs if work profile 
      # otherwise use patched nixos-unstable nixpkgs
      pkgs = (if ((systemSettings.profile == "work") || (systemSettings.profile == "work2"))
              then
                pkgs-stable
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
