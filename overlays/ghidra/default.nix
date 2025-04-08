# From your overlays/ghidra/default.nix
final: prev: {
  # Import the extensions
  ghidraExtensions = prev.ghidraExtensions or {} // {
    golang-analyzer = final.callPackage ./extensions/golang-analyzer.nix {};
  };

  # Create Ghidra with the extensions
  ghidra = prev.ghidra.override {  # This line replaces the default ghidra
    extensions = (prev.ghidra.extensions or []) ++ [
      final.ghidraExtensions.golang-analyzer
    ];
  };
}
