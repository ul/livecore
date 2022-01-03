## Metronomes and other triggers

import frame

type
  Metro* = object
    frame: int
    nextTrigger: int

proc metro*(freq: float, s: var Metro): float =
  if unlikely(s.frame >= s.nextTrigger):
    s.nextTrigger = s.frame + (SAMPLE_RATE / freq).int
    result = 1.0
  s.frame.inc
lift1(metro, Metro)

proc dmetro*(dt: float, s: var Metro): float =
  if unlikely(s.frame >= s.nextTrigger):
    s.nextTrigger = s.frame + (SAMPLE_RATE * dt).int
    result = 1.0
  s.frame.inc
lift1(dmetro, Metro)

proc phsclk*(x, n: float, s: var float): float =
  ## https://pbat.ch/sndkit/phsclk/
  ## NB it expects phase in 0..1, not -1..1
  if likely(x < 1.0):
    let
      p = s * n
      q = x * n
    if unlikely(p.floor != q.floor):
      result = 1.0
  s = x
lift2(phsclk, float)

proc bpm2freq*(bpm: float): float = bpm / 60.0
proc bpm2delta*(bpm: float): float = 60.0 / bpm
lift1(bpm2freq)
lift1(bpm2delta)
