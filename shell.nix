with (import <nixpkgs> { });
mkShell {
  buildInputs = [ nim lld fswatch liblo libsndfile ]
    ++ (with darwin.apple_sdk.frameworks; [ AudioUnit CoreAudio ]);
}
