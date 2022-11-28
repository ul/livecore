import std/sugar
import controls, timespan

type State* = object
  span*: TimeSpan
  controls*: Controls

# TODO This is a bad idea but we don't use Controls yet.
converter to_state*(span: TimeSpan): State =
  State(span: span, controls: Controls())

func set_span*(s: State, span: TimeSpan): State =
  State(span: span, controls: s.controls)

func set_controls*(s: State, controls: Controls): State =
  State(span: s.span, controls: controls)

proc with_span*(s: State, f: TimeSpan -> TimeSpan): State =
  s.set_span(f(s.span))

when isMainModule:
  import std/unittest
  suite "State":
    test "set_span":
      let s = State(span: TimeSpan(begin: 1//2, `end`: 3//2),
          controls: Controls())
      check s.set_span(TimeSpan(begin: 1, `end`: 2)).span == TimeSpan(begin: 1, `end`: 2)
      check s.set_span(TimeSpan(begin: 1, `end`: 2)).controls == s.controls
    test "set_controls":
      let s = State(span: TimeSpan(begin: 1//2, `end`: 3//2),
          controls: Controls())
      check s.set_controls(Controls({"a": 1.0}.to_table)).span == s.span
      check s.set_controls(Controls({"a": 1.0}.to_table)).controls == Controls({
          "a": 1.0}.to_table)
    test "with_span":
      let s = State(span: TimeSpan(begin: 3//2, `end`: 5//2),
          controls: Controls())
      check s.with_span((x: TimeSpan) => x.cycle_arc).span == TimeSpan(
          begin: 1//2, `end`: 3//2)
      check s.with_span((x: TimeSpan) => x.cycle_arc).controls == s.controls
