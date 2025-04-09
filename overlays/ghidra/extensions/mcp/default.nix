{
  lib,
  fetchFromGitHub,
  fetchurl,
  buildGhidraExtension,
}:

buildGhidraExtension rec {
  pname = "GhidraMCP";
  version = "1.1";
  
  # src = fetchFromGitHub {
  #   owner = "LaurieWired";
  #   repo = "GhidraMCP";
  #   rev = version;
  #   hash = "sha256-be2Ij21r0yrFw/JmhsEh2XFFLb6KjvKrf12+boNqAGY=";
  # };

  dontUnpack = true;
  dontBuild = true;

  src = fetchurl {
    url = "https://github.com/LaurieWired/GhidraMCP/releases/download/${version}/GhidraMCP-release-1-1.zip";
    hash = "sha256-WHwlwo8sV7t9irFKg0gOOzL04wvfhf+WElRVa9lAnus=";
  };

  # installPhase = ''
  #   runHook preInstall
  #
  #   echo "Installing GhidraMCP extension..."
  #   echo "Source: $src"
  #   
  #   mkdir -p $out/lib/ghidra/Ghidra/Extensions
  #   unzip -d $out/lib/ghidra/Ghidra/Extensions $src
  #   
  #   runHook postInstall
  # '';

  installPhase = ''
    runHook preInstall
    
    # Create a temporary directory to extract the outer ZIP
    mkdir -p $TMPDIR/extract
    unzip -q $src -d $TMPDIR/extract
    
    # Find the actual extension ZIP file (should be GhidraMCP-1-1.zip inside)
    EXTENSION_ZIP=$(find $TMPDIR/extract -name "*.zip" -not -name "$(basename $src)" -print -quit)
    
    if [ -z "$EXTENSION_ZIP" ]; then
      echo "Error: Could not find extension ZIP file inside the release archive"
      exit 1
    fi
    
    # Create the target directory and copy the extension ZIP
    # mkdir -p $out/lib/ghidra/Ghidra/Extensions
    # cp "$EXTENSION_ZIP" $out/lib/ghidra/Ghidra/Extensions/

    mkdir -p $out/lib/ghidra/Ghidra/Extensions/
    unzip -q "$EXTENSION_ZIP" -d $out/lib/ghidra/Ghidra/Extensions/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP Server for Ghidra - enables LLMs to autonomously reverse engineer applications";
    homepage = "https://github.com/LaurieWired/GhidraMCP";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
