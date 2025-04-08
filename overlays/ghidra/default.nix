# overlays/ghidra/default.nix
final: prev: {
  # Import the extension
  ghidraExtensions = prev.ghidraExtensions or {} // {
    golangAnalyzer = final.callPackage ./extensions/test.nix {};
  };
}
