{
  description = "Example nix-nuget-feed consumer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-nuget-feed.url = "github:9Prestidigitator/nix-nuget-feed";
    myNixDerivedLib.url = "path:./MyNixDerivedLib";
  };

  outputs = {
    nixpkgs,
    nix-nuget-feed,
    myNixDerivedLib,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = nix-nuget-feed.lib {
      inherit pkgs;

      # This is where you import your nuget derivations
      nugetPackages = [
        myNixDerivedLib.packages.${system}.default
      ];

      packages = with pkgs; [
        dotnet-sdk_10
        nuget

        omnisharp-roslyn
        netcoredbg
        csharpier

        nixd
        alejandra
      ];
    };
  };
}
