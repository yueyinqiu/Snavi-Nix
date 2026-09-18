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
    name = cfg.runName;
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

    enableBashIntegration = lib.mkEnableOption "a `snavi` shell function that runs the cheats and saves the result to history";

    runName = lib.mkOption {
      type = lib.types.str;
      default = "snavi-run";
      description = "Name of the generated `snavi-run` wrapper.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      snaviRun
    ];

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      snavi() {
        local result="$("${snaviRun}/bin/${cfg.runName}")"
        echo "$result"
        history -s -- "$result"
        echo "Saved to history."
      }
    '';
  };
}
