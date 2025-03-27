# ../../overlays/simple-test.nix
final: prev: {
  simple-test-package = prev.hello.overrideAttrs (old: {
    name = "simple-test-package";
  });
}
