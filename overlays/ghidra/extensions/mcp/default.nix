{
  lib,
  fetchFromGitHub,
  buildGhidraExtension,
}:

buildGhidraExtension rec {
  pname = "GhidraMCP";
  version = "1.1";
  
  # src = fetchurl {
  #   url = "https://github.com/LaurieWired/GhidraMCP/releases/download/1.1/GhidraMCP-1-1.zip";
  #   hash = "sha256-be2Ij21r0yrFw/JmhsEh2XFFLb6KjvKrf12+boNqAGY="; # Your provided hash
  # };

  src = fetchFromGitHub {
    owner = "LaurieWired";
    repo = "GhidraMCP";
    rev = version;
    hash = "sha256-be2Ij21r0yrFw/JmhsEh2XFFLb6KjvKrf12+boNqAGY=";
  };

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    unzip -d $out/lib/ghidra/Ghidra/Extensions $src
    
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
