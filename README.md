# LiveCore

A hardcore livecoding system for realtime audio synth in [the spirit of Sound Garden](http://ul.mantike.pro/sound-garden-manifesto.html).
WIP with
[Work with the garage door up](https://notes.andymatuschak.org/Work_with_the_garage_door_up) ethos.

## Influences

- [clive](https://mathr.co.uk/clive/)
- [Extempore](https://extemporelang.github.io)
- Sound Garden [1](https://github.com/ul/sound-garden) & [2](https://github.com/ul/sound-garden-0x2)
- [Ad Libitum](https://github.com/ul/ad-libitum)
- [Strudel](https://github.com/tidalcycles/strudel)

## Dependencies

- [Nim](https://nim-lang.org) 1.7.3 (d26b1232ee7a69c2a71db81aa0185499321c54fe)
- [fswatch](http://emcrisostomo.github.io/fswatch/) 1.17.1
- [libsndfile](http://www.mega-nerd.com/libsndfile/) 1.1.0
- [liblo](http://liblo.sourceforge.net/) 0.31

On macOS:

```
$ brew install fswatch libsndfile liblo
or
$ port install fswatch libsndfile liblo
```

For Nim try [choosenim](https://github.com/dom96/choosenim#choosenim).
You'll need to use `devel` version as the latest stable at the time of writing
(1.6.10) had a GC bug crashing LiveCore.

There is also `shell.nix` for Nix users but bear in mind that at the time of
writing it's installing a version with GC bug (1.6.8).

## Configuration

Sample rate and channels count is hardcoded to `48000` and `2` respectively.
If your device requires different values, edit `src/dsp/frame.nim`.

## Session workflow

NB: you need to run all the mentioned scripts from the repo root.

- Checkout starting point. For a fresh session the `main` branch is a good choice.
- Make sure that the git tree is clean, as this script will be committing your
  changes as you make them.
- Start server with `./start-server`
- Run `./start-session` with a session name as an argument.
  It must be valid as a part of git branch name as the script will prefix it with
  `session/` and checkout this branch.
- If the session with such name exists it will be resumed.
- Make changes in `src/session.nim` and save file to compile and send to the server.
- After every successful compilation there will be a commit.
- Ctrl-C this script to stop and switch back to the starting point.
- The system is ready for the next session!

## Render

To render a specific session duration in a non-interactive mode to a file:

```
$ ./render <duration in seconds> <path/to/output.wav>
```

## Examples

Peek into `src/session.nim` in `session/*` branches.

## License

This project is licensed under [BSD-3-Clause](./LICENSE), with the exception of
derivative work that is covered either by licenses defined via `LICENSE` files
in the corresponding sub-directories or via comments directly in the source code
files.

## FAQ

### Why Nim?

C-like freedom, performance and fast compilation with heaps of syntactic sugar.
clive very much aligns with the vision I wanted to implement and I'd just port
clive to macOS if only C was terser. When I'm jamming I want the code to be
clean, concise and close to my intention, all other necessary trade-offs
considered.

### Does it run on Windows/Linux?

Maybe. Please try and let me know! I strive to write the code in a
platform-independent way but I test it only on macOS.

### Why snake_case procs and vars?

Purely irrational, æsthetic choice. CamelCase seems to be prevalent in the Nim
ecosystem, and majority of the code I write/read in other languages is camelCase
too. However, I enjoy the most writing/reading OCaml and Rust in the regard of
that particular convention, and I'm glad that Nim's compiler doesn't actually
care, so I went with underscores.
