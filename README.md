# nix-nuget-feed

This nix library allows users to create a development shell containing nix-derived nuget packages.

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
devshells.default = inputs.nix-nuget-feed.lib {
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
  devshells.default = pkgs.mkShell {
    nugetPackages = [
      inputs.myDotnetLib1.packages.${system}.default
      inputs.myDotnetLib2.packages.${system}.default
    ];
    # Other development shell options...
  }
}
```

## Inspirations

- [nuget-packageslock2nix](https://github.com/mdarocha/nuget-packageslock2nix): A great way to get your nuget.org packages into the nix store.
