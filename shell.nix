with (import <nixpkgs> { });
mkShell {
  buildInputs = [ nim lld fswatch libsndfile ] ++ (if stdenv.isDarwin then
    (with darwin.apple_sdk.frameworks; [ AudioUnit CoreAudio ])
  else
    [ ]) ++ (if stdenv.isLinux then [ alsa-lib ] else [ ]);
  LD_LIBRARY_PATH = if stdenv.isLinux then
    lib.makeLibraryPath [ stdenv.cc.cc alsa-lib ]
  else
    "";
}
