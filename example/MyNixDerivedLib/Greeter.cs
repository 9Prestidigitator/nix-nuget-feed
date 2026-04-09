/// <summary>
/// This should be availabe on ExampleApp.cs after entering the development
/// environment and setting the NuGet.Config properly.
/// </summary>
namespace MyNixDerivedLib;

/// <summary>
/// This is the class that will be used in the ExampleApp!
/// </summary>
public static class Greeter
{
    /// <summary>
    /// Returns a simple greeting string!
    /// </summary>
    public static string Greet(string name) => $"Hello, {name}, from a nix-derived nuget package!";
}
