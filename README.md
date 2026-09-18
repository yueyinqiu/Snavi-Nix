# Snavi-Nix

Nix packaging for [Snavi](https://github.com/yueyinqiu/Snavi) — a [navi](https://github.com/denisidoro/navi)-like interactive command-line cheatsheet tool with structured cheat files and C# script support.

## Adding as a flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    snavi.url = "github:yueyinqiu/Snavi-Nix";
  };
}
```

## Package

The binary is exposed as `Snavi`:

```nix
snavi.packages.${system}.snavi
```

Or try it directly from the CLI:

```console
$ nix shell github:yueyinqiu/Snavi-Nix
```

## home-manager

Add it to your user environment via `home.packages`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    snavi.url = "github:yueyinqiu/Snavi-Nix";
  };

  outputs = { home-manager, snavi, ... }: {
    homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
      modules = [
        ({ pkgs, ... }: {
          home.packages = [
            snavi.packages.${pkgs.system}.snavi
            pkgs.fzf
            pkgs.dotnetCorePackages.sdk_10_0
          ];
        })
      ];
    };
  };
}
```

---

All documentation and `description` fields in this repository are AI-generated.
