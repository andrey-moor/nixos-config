# overlays/ghidra/default.nix
final: prev: {
  ghidra = prev.ghidra // {
    passthru = prev.ghidra.passthru or {} // {
      extensions = prev.lib.makeScope prev.newScope (self: 
        # Get the original extensions
        let 
          originalExtensions = prev.ghidra.passthru.extensions;
          originalExtensionsSet = builtins.listToAttrs 
            (map (name: { inherit name; value = originalExtensions.${name}; }) 
                (builtins.attrNames originalExtensions));
        in
        originalExtensionsSet // {
          # Add your custom extension - note the updated path
          golang-analyzer = self.callPackage ./extensions/golang-analyzer.nix {};
          
          # You can add more extensions here
          # another-extension = self.callPackage ./extensions/another-extension.nix {};
        }
      );
    };
  };
}
