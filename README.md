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
