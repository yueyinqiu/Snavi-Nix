{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.snavi;

  makeSnaviRun = import ../lib/make-snavi-run.nix pkgs;

  snaviRun = makeSnaviRun {
    snavi = cfg.package;
    dotnet = cfg.dotnet;
    fzf = cfg.fzf;
    name = cfg.wrapperName;
    cheats = builtins.attrValues cfg.cheats;
  };
in
{
  options.programs.snavi = {
    enable = lib.mkEnableOption "Snavi";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../package { };
      description = "The Snavi package to install.";
    };

    installOriginalPackage = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to also add the original `Snavi` package to the user PATH.";
    };

    dotnet = lib.mkOption {
      type = lib.types.package;
      default = pkgs.dotnetCorePackages.sdk_10_0;
      description = "The dotnet package used by Snavi to run C# scripts.";
    };

    fzf = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fzf;
      description = "The fzf package used by Snavi for interactive selection.";
    };

    cheats = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            src = lib.mkOption {
              type = lib.types.path;
              description = ''
                Directory containing the cheat entry and any helper files it
                references (e.g. `.cs` suggesters). The whole directory is
                copied so relative references keep working.
              '';
            };

            entry = lib.mkOption {
              type = lib.types.str;
              description = "Path to the cheat entry, relative to `src`.";
            };
          };
        }
      );
      default = { };
      description = "Snavi cheats to install, keyed by name.";
    };

    enableBashIntegration = lib.mkEnableOption "a readline widget that runs Snavi on `Ctrl-g`";

    wrapperName = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name of the generated wrapper. Defaults to `"snavi-run"` when
        `installOriginalPackage` is enabled, and `"snavi"` otherwise.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.snavi.wrapperName = lib.mkDefault (
      if cfg.installOriginalPackage then "snavi-run" else "snavi"
    );

    home.packages =
      [
        snaviRun
      ]
      ++ lib.optional cfg.installOriginalPackage cfg.package;

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      _snavi_bind() {
        READLINE_LINE="$("${snaviRun}/bin/${cfg.wrapperName}")"
        READLINE_POINT=''${#READLINE_LINE}
      }
      bind -x '"\C-g": _snavi_bind'
    '';
  };
}
