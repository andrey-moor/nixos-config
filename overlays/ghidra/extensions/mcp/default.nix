{
  lib,
  fetchFromGitHub,
  maven,
  buildGhidraExtension,
}:

buildGhidraExtension rec {
  pname = "GhidraMCP";
  version = "1.0";
  
  src = fetchFromGitHub {
    owner = "LaurieWired";
    repo = "GhidraMCP";
    rev = "86b257a"; # Commit hash from the 1.0 release
    hash = "sha256-L7pMAOkbkn8sYpO16qN3ypzJ8KW7xn6AZnxR0iZ+3+0="; # Replace with actual hash
  };
  
  nativeBuildInputs = [ maven ];
  
  # Add Maven build process
  preBuild = ''
    # Maven uses this directory to store repository cache
    export MAVEN_OPTS="-Dmaven.repo.local=$out/.m2"
  '';
  
  # Use Maven to build the extension
  buildPhase = ''
    mvn clean package assembly:single
  '';
  
  # The built extension is in the target directory
  installPhase = ''
    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    cp target/${pname}-${version}.zip $out/lib/ghidra/Ghidra/Extensions
  '';
  
  meta = with lib; {
    description = "MCP Server for Ghidra - enables LLMs to autonomously reverse engineer applications";
    homepage = "https://github.com/LaurieWired/GhidraMCP";
    license = licenses.mit; # Verify the actual license
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
