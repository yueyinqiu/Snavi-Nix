{
  description = "Nix packaging for Snavi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      packages = forAllSystems (
        system:
        let
          package = nixpkgs.legacyPackages.${system}.callPackage ./package { };
        in
        {
          snavi = package;
          default = package;
        }
      );

      lib = forAllSystems (system: {
        makeSnaviRun = import ./lib/make-snavi-run.nix nixpkgs.legacyPackages.${system};
      });

      homeManagerModules =
        let
          module = ./home-manager-module;
        in
        {
          snavi = module;
          default = module;
        };
    };
}
