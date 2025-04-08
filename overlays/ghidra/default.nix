# custom-ghidra-overlay.nix
final: prev: {
  ghidra = prev.ghidra // {
    passthru = prev.ghidra.passthru or {} // {
      extensions = prev.lib.makeScope prev.newScope (self: 
        # Import the original extensions
        (prev.ghidra.passthru.extensions.unscope) // {
          # Add your custom extension
          golang-analyzer = self.callPackage ./extensions/golang-analyzer.nix {};
          
          # You can add multiple extensions
          # another-extension = self.callPackage ./another-extension.nix {};
        }
      );
    };
  };
}
