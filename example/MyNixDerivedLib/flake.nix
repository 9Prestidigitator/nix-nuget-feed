{
  description = "Example nix-derived nuget package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix";
      inputs.nixpkgs.follow = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nuget-packageslock2nix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.buildDotnetModule {
      pname = "MyNixDerivedLib";
      version = "1.0.0";
      src = ./.;
      projectFile = "MyNixDerivedLib.csproj";
      nugetDeps = nuget-packageslock2nix.lib {
        name = "MyNixDerivedLib";
        lockfiles = [./packages.lock.json];
      };
      dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
      dotnet-runtime = pkgs.dotnetCorePackages.runtime_10_0;
      packNupkg = true;
    };
  };
}
