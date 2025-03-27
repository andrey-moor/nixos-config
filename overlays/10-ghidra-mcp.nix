final: prev: {
  # Test attribute to verify overlay is loaded
  my-test-attr = "overlay loaded successfully";

  # Create a custom Ghidra with the GhidraMCP extension and other extensions
  ghidra-with-extensions = prev.ghidra.withExtensions (
    extensions: with prev; with extensions; [
      # Standard extensions from nixpkgs
      kaiju
      ret-sync
      # Add other standard extensions as needed:
      # gnudisassembler
      # lightkeeper
      # wasm
      
      # Custom GhidraMCP extension
      (extensions.buildGhidraExtension {
        pname = "ghidra-mcp";
        version = "1.0.6";  # Current version at time of writing

        src = prev.fetchFromGitHub {
          owner = "LaurieWired";
          repo = "GhidraMCP";
          rev = "v1.0.6";
          hash = "sha256-2/xFFmzPCpMn6JEBrhNJ8OXrAkdWUcGQwLZ0Pzavzks=";
        };

        # The extension is built using Maven
        nativeBuildInputs = with prev; [
          maven
        ];

        # Build the extension
        buildPhase = ''
          mvn clean package assembly:single
        '';

        # Extract the built ZIP to the output directory
        installPhase = ''
          mkdir -p $out/dist
          find . -name "*.zip" -exec cp {} $out/dist/ \;
        '';

        meta = with prev.lib; {
          description = "Model Context Protocol (MCP) server for Ghidra, enabling LLMs to reverse engineer software";
          homepage = "https://github.com/LaurieWired/GhidraMCP";
          license = licenses.mit;
          maintainers = [ ];
          platforms = platforms.all;
        };
      })
    ]
  );
}
