with (import <nixpkgs> { });
mkShell {
  buildInputs = [
    nim
    lld
    fswatch
    liblo
    libsndfile
    darwin.apple_sdk.frameworks.CoreAudio
    darwin.apple_sdk.frameworks.AudioUnit
  ];
}
