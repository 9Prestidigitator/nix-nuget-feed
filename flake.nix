{
  description = "Nuget feed devshell helper";

  outputs = {
    lib.mkDotnetShell = {
      pkgs,
      localNugetPackages ? [],
      ...
    } @ args: let
      localNugetFeed =
        pkgs.runCommand "local-nuget-feed" {
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
            localNugetPackages
          }
        '';

      # Strip our custom args before forwarding to mkShell
      shellArgs = removeAttrs args ["pkgs" "localNugetPackages"];
    in
      pkgs.mkShell (shellArgs
        // {
          env =
            (args.env or {}) // {NIX_NUGET = localNugetFeed;};
        });
  };
}
