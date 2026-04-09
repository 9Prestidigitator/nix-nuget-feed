namespace MyNixDerivedLib;

public static class Greeter
{
    public static string Greet(string name) => $"Hello, {name}, from a nix-derived nuget package!";
}
