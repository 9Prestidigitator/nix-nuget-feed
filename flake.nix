{
  description = "Nuget feed devshell helper";

  outputs = {...}: let
    mkNugetFeed = pkgs: nugetPackages:
      pkgs.runCommand "nix-nuget-feed" {
        buildInputs = [pkgs.zip pkgs.libxml2];
      } ''
        mkdir -p $out
        ${
          pkgs.lib.concatMapStringsSep "\n"
          (pkg: ''
            for versionDir in ${pkg}/share/nuget/packages/*/*; do
              version=$(basename "$versionDir")
              nuspec=$(find "$versionDir" -name "*.nuspec" | head -1)
              pname=$(xmllint --xpath "string(//*[local-name()='id'])" "$nuspec")
              (cd "$versionDir" && zip -r "$out/$pname.$version.nupkg" . && chmod 775 $out/*)
            done
          '')
          nugetPackages
        }
      '';
  in {
    overlays.default = final: prev: {
      mkShell = {nugetPackages ? [], ...} @ args: let
        shellArgs = removeAttrs args ["nugetPackages"];
      in
        prev.mkShell (shellArgs
          // {
            env =
              (args.env or {})
              // prev.lib.optionalAttrs
              (nugetPackages != [])
              {NIX_NUGET = mkNugetFeed prev nugetPackages;};
          });
    };
    lib = {
      pkgs,
      nugetPackages ? [],
      ...
    } @ args: let
      shellArgs = removeAttrs args ["pkgs" "nugetPackages"];
    in
      pkgs.mkShell (shellArgs
        // {
          env = (args.env or {}) // pkgs.lib.optionalAttrs (nugetPackages != []) {NIX_NUGET = mkNugetFeed pkgs nugetPackages;};
        });
  };
}
