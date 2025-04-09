self: super:

{
  ghidra-with-my-extensions = super.ghidra.passthru.withExtensions (extensions: [
    # Import your custom extension
    (super.callPackage ./extensions/golang-analyzer {
      buildGhidraExtension = super.ghidra.passthru.buildGhidraExtension;
    })
    
    # You can also include standard extensions from ghidra-extensions
    extensions.ret-sync
  ]);
}
