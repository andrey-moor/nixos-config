final: prev: {
  # Define your extension
  ghidraExtensions = prev.ghidraExtensions or {} // {
    test = final.callPackage ./extensions/test.nix {};
  };

  # Create a custom Ghidra package with your extension
  ghidra-with-extensions = prev.ghidra.override {
    # Include both the existing extensions and your new one
    extensions = (prev.ghidra.extensions or []) ++ [
      final.ghidraExtensions.test
    ];
  };

  # Replace the default ghidra package (optional)
  ghidra = final.ghidra-with-extensions;
}
