pkgs:
{
  snavi ? pkgs.callPackage ../package { },
  dotnet ? pkgs.dotnetCorePackages.sdk_10_0,
  fzf ? pkgs.fzf,
  cheats,
  name,
}:
let
  args = pkgs.lib.concatMap (cheat: [
    "-c"
    "${
      builtins.path {
        path = cheat.src;
        name = "${name}-cheat";
        recursive = true;
      }
    }/${cheat.entry}"
  ]) cheats;
in
pkgs.writeShellApplication {
  name = name;
  text = ''
    exec "${snavi}/bin/Snavi" run \
      --dotnet "${dotnet}/bin/dotnet" \
      --fzf "${fzf}/bin/fzf" \
      ${pkgs.lib.escapeShellArgs args}
  '';
}
