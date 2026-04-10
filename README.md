# nix-nuget-feed

This nix library allows users to create a development shell containing nix-derived nuget packages.

## What problem this solves

Imagine you have a .NET project A that is a dependency of another project B via NuGet. If you have buildDotnetModule derivations for both, then simply give A's derivation `packNupkg = true` and pass it to B's `projectReferences`. `nix build .#B` works perfectly.
However this only works when building through nix. There is no way to use `dotnet build`, `dotnet restore`, `dotnet run`, etc. and have them see those same nix-derived nuget packages. This means your local dotnet tooling and your nix derivations are operating on different package graphs, this can hide bugs and makes iterative development painful.
`nix-nuget-feed` solves this by repacking your nix-derived nuget packages and exposing them as a local NuGet feed in your dev shell. The packages your local dotnet commands restore from are the exact same derivations your nix build uses.

## Setup

You must add this line to your solution/projects `NuGet.Config` file:

```xml
<!-- ... -->
  <packageSource>
    <!-- ... -->
    <add key="Nix Nuget" value="%NIX_NUGET%" />
    <!-- ... -->
  </packageSource>
<!-- ... -->
```

The `.nupkg` files will then be available via the environment variable `%NIX_NUGET%`.

**Note:**
When using [build-nuget-module](https://github.com/NixOS/nixpkgs/blob/96e87bd250d5f4f3447b87ab7e94689ea19e0c2a/pkgs/build-support/dotnet/build-dotnet-module/default.nix#L4) to derive a nuget packages you must have `packNupkg=true`. This ensures the .nupkg file is properly unloaded in the nix store.

## Usage

Simply add this library as a flake input:

```nix
inputs = {
  nix-nuget-feed.url = "github:9Prestidigitator/nix-nuget-feed";
}
```

You can now create a nix-nuget-feed development shell via the single library or an overlay.

### Library

```nix
devShells.default = inputs.nix-nuget-feed.lib {
  inherit pkgs;
  nugetPackages = [
    inputs.myDotnetLib1.packages.${system}.default
    inputs.myDotnetLib2.packages.${system}.default
  ];
  # Other development shell options...
}
```

### Overlay

```nix
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ inputs.nix-nuget-feed.overlays.default ];
  }
in
{
  devShells.default = pkgs.mkShell {
    nugetPackages = [
      inputs.myDotnetLib1.packages.${system}.default
      inputs.myDotnetLib2.packages.${system}.default
    ];
    # Other development shell options...
  }
}
```

You should now be able to build your dotnet project that relies on a inputed nix-derived nuget package.

## Example

You can try with the included example:

```bash
cd ./example
nix develop .
dotnet build ./ExampleApp
```

This will take the `MyNixDerivedLib` flake and provide it as a valid nuget package that is recognized by dotnet.

## How it works

Each nix-derived nuget package built with `packNupkg=true` stores its extracted contents in `$out/share/nuget/packages/<pname>/<version>/`. This library collects those directories, reads the package name from each `.nuspec` file to preserve original casing, and repacks them into proper `.nupkg` zip archives inside a single nix store derivation. The path to that derivation is then exposed as `NIX_NUGET` in your development shell, which NuGet reads as a local package source feed. When you run `dotnet restore`, NuGet resolves packages from this feed and extracts them into your global cache (`~/.nuget/packages`) as normal.

This repository exists to reduce boiler-plate, the steps are pretty simple but I use it in a lot of real C#/Nix projects.

## Inspirations

- [nuget-packageslock2nix](https://github.com/mdarocha/nuget-packageslock2nix): A great way to get your nuget.org packages into the nix store.
