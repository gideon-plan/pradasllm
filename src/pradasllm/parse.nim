## parse.nim -- Parse LLM response into variable assignments.
{.experimental: "strict_funcs".}
import std/[strutils, tables]

type
  BridgeError* = object of CatchableError

import basis/code/choice
proc parse_assignments*(response: string): Choice[Table[string, int]] =
  var assignments: Table[string, int]
  for line in response.splitLines():
    let trimmed = line.strip()
    if trimmed.len == 0: continue
    let eq = trimmed.find('=')
    if eq > 0:
      let k = trimmed[0 ..< eq].strip()
      let v = trimmed[eq+1 ..< trimmed.len].strip()
      try: assignments[k] = parseInt(v)
      except ValueError: continue
  if assignments.len == 0:
    return bad[Table[string, int]]("pradasllm", "no valid assignments")
  good(assignments)
