{
  lib,
  fetchFromGitHub,
  buildGhidraExtension,
}:
buildGhidraExtension rec {
  pname = "Ghidra-GolangAnalyzerExtension";
  version = "1.3.7";

  src = fetchFromGitHub {
    owner = "mooncat-greenpy";
    repo = "Ghidra_GolangAnalyzerExtension";
    rev = version;
    hash = "sha256-pFvwTJy0DhCG/O1HxoDLRY59kNs4hAEIfBLYBkfM3YU=";
  };

  meta = {
    description = "Facilitates the analysis of Golang binaries using Ghidra";
    homepage = "https://github.com/mooncat-greenpy/Ghidra_GolangAnalyzerExtension";
    downloadPage = "https://github.com/mooncat-greenpy/Ghidra_GolangAnalyzerExtension/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}