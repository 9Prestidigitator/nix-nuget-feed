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
      nugetPackages = [
        myNixDerivedLib.packages.${system}.default
      ];
      packages = [pkgs.dotnet-sdk_10];
    };
  };
}
