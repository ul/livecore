with (import <nixpkgs> { });
mkShell {
  buildInputs = [ nim lld fswatch libsndfile ]
    ++ (with darwin.apple_sdk.frameworks; [ AudioUnit CoreAudio ]);
}
