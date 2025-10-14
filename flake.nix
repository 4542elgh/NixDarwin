{
  description = "Evan nix-darwin system flake";

  # This is all your git source for different modules
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # This will be the darwin packages you want to build
  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, nix-homebrew }:
  {
    darwinPackages = self.darwinConfigurations."evanmbp".pkgs;
    allowUnsupportedSystem = true;

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."evanmbp" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix {
            # Need to pass self explicitly
            _module.args = { inherit self; };
        }

        home-manager.darwinModules.home-manager
        {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup"; # <-- You have to set this.

                users.evanliu = import ./home.nix;
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
        }

        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            user = "evanliu";
          };
        }
      ];
    };

    darwinConfigurations."Evans-MacBook-Pro" = self.darwinConfigurations."evanmbp";
  };
}
