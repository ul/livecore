import
  std/macros,
  frame

macro defnotes() =
  result = nnk_stmt_list.new_tree
  for (name, offset) in [
    ("c", 0),
    ("d", 2),
    ("e", 4),
    ("f", 5),
    ("g", 7),
    ("a", 9),
    ("b", 11)
  ]:
    for octave in 0..8:
      let k = ident(name & $octave)
      let v = (12*(octave+1) + offset).to_float.midi2freq
      let note = quote do:
        const `k`* = `v`
      result.add(note)

defnotes()

when isMainModule:
  import std/unittest
  suite "notes":
    test "const":
      check a4 == 69.midi2freq
      check c3 == 48.midi2freq
