with (import <nixpkgs> { });
mkShell.override { stdenv = llvmPackages_14.stdenv; } {
  buildInputs = [
    nim
    lld_14
    fswatch
    liblo
    libsndfile
    darwin.apple_sdk.frameworks.CoreAudio
    darwin.apple_sdk.frameworks.AudioUnit
    entr
  ];
}
