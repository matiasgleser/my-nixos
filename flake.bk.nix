{

  description = "Flake of Matias Gleser";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";  # Sets NixPkgs version (currently latest stable)
    home-manager.url = "github:nix-community/home-manager/release-24.05";  # Sets NixPkgs version (must be the same as nixpkgs, master if following unstable branch)
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Make sure home-manager uses the same pkgs version as nixpkgs
  };

  outputs = { self, nixpkgs, home-manager, ... }: 
    # Define systems configs
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";  # System architecture
      pkgs = nixpkgs.legacyPackages.${system};  # Used in home-manager pkgs config
    in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;  
        modules = [
          ./configuration.nix
        ];
      };
    };

    # Define home-manager configs
    homeConfigurations = {
      mati = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];

      };      
    };

  };

}
