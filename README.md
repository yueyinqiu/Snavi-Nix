# Snavi-Nix

Nix packaging for [Snavi](https://github.com/yueyinqiu/Snavi) — a [navi](https://github.com/denisidoro/navi)-like interactive command-line cheatsheet tool with structured cheat files and C# script support.

## Adding as a flake input

```nix
{
  inputs = {
    snavi.url = "github:yueyinqiu/Snavi-Nix";
  };
}
```

> To avoid building from source, you can use the `yueyinqiu` Cachix binary cache:
> 
> ```nix
> {
>   nix.settings.extra-substituters = [
>     "https://yueyinqiu.cachix.org"
>   ];
>   nix.settings.extra-trusted-public-keys = [
>     "yueyinqiu.cachix.org-1:iooLFYpS7e6KAU4+QM5Zoj6Tq76jRGo+kjeAbu8JxAc="
>   ];
> }
> ```

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

A module is exposed as `homeManagerModules.snavi` (also available as
`homeManagerModules.default`):

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
        snavi.homeManagerModules.snavi
        {
          programs.snavi = {
            enable = true;
            # package = snavi.packages.x86_64-linux.snavi;  # optional, defaults to it

            cheats.commit = { src = ./cheats/git; entry = "commit.json"; };
            cheats.checkout = { src = ./cheats/git; entry = "checkout.json"; };
            cheats.cat = { src = ./cheats/cat; entry = "cat.json"; };
          };
        }
      ];
    };
  };
}
```

Options under `programs.snavi`:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `enable` | bool | `false` | Whether to enable Snavi |
| `package` | package | this flake's `snavi` | The `Snavi` package to install |
| `installOriginalPackage` | bool | `false` | Whether to also add the original `Snavi` package to the user PATH |
| `dotnet` | package | `pkgs.dotnetCorePackages.sdk_10_0` | dotnet used to run C# scripts |
| `fzf` | package | `pkgs.fzf` | fzf used for interactive selection |
| `cheats` | attrsOf submodule | `{ }` | Cheats to install, keyed by name |
| `enableBashIntegration` | bool | `false` | Bind a readline widget that runs Snavi on `Ctrl-g` |
| `wrapperName` | str | `"snavi-run"` if `installOriginalPackage`, else `"snavi"` | Name of the generated wrapper |

Each cheat in `cheats` accepts:

| Name | Type | Description |
| --- | --- | --- |
| `src` | path | Directory containing the cheat entry and helper files (e.g. `.cs` suggesters) |
| `entry` | str | Path to the cheat entry, relative to `src` |

Enabling the module installs a wrapper (named `snavi` by default) that passes
each cheat's entry to Snavi via `-c`. Set `installOriginalPackage = true` to
also put the original `Snavi` binary on the PATH. The `src` directory is copied
as a whole, so helper files referenced relative to the entry keep working.

## Lib

`makeSnaviRun` builds the `snavi-run` wrapper from a list of cheats:

```nix
snavi.lib.${system}.makeSnaviRun {
  snavi = snavi.packages.${system}.snavi;
  dotnet = pkgs.dotnetCorePackages.sdk_10_0;   # optional
  fzf = pkgs.fzf;                              # optional
  cheats = [
    { src = ./cheats/git; entry = "commit.json"; }
    { src = ./cheats/git; entry = "checkout.json"; }
    { src = ./cheats/cat; entry = "cat.json"; }
  ];
  name = "snavi-run";
}
```

Parameters:

| Name | Default | Description |
| --- | --- | --- |
| `snavi` | this flake's `snavi` | The `Snavi` binary to run |
| `dotnet` | `pkgs.dotnetCorePackages.sdk_10_0` | dotnet used to run C# scripts |
| `fzf` | `pkgs.fzf` | fzf used for interactive selection |
| `cheats` | (required) | List of `{ src, entry }`: each entry is passed via `-c` |
| `name` | (required) | Name of the generated wrapper |

---

All documentation and `description` fields in this repository are AI-generated.
