{
    description = "Home-manager configuration";
    
    inputs = {
        utils.url = "github:numtide/flake-utils";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    }

    outputs = { self, home-manager, nixpkgs, utils }:
        let
            pkgsForSystem = system: import nixpkgs {
                inherit system;
            };

            mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
                system = args.system or "x86_64-linux";
                configuration = import ./home.nix;
                homeDirectiory = "/home/lucy";
                username = "lucy";
                pkgs = pkgsForSystem system;
            } // args);

        in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
            legacyPackages = pkgsForSystem system;
        }) // {
            # non-system suffixed items should go here
            nixosModules.home = import ./home.nix; # attr set or list

            homeConfigurations.lucy = mkHomeConfiguration {
                extraSpecialArgs = {
                    withGUI = true;
                    isDesktop = true;
                    networkInterface = "enp1s0";
                };
            };

            inherit home-manager;
        };
}