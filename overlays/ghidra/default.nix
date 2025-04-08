# From your overlays/ghidra/default.nix
final: prev: {
  # Import the extension
  ghidraExtensions = prev.ghidraExtensions or {} // {
    test = final.callPackage ./extensions/test.nix {};
  };

  # Create Ghidra with the extension
  ghidra = prev.ghidra.override {  # This line replaces the default ghidra
    extensions = (prev.ghidra.extensions or []) ++ [
      final.ghidraExtensions.test
    ];
  };
}
