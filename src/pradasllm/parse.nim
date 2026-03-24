## parse.nim -- Parse LLM response into variable assignments.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import lattice
proc parse_assignments*(response: string): Result[Table[string, int], BridgeError] =
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
    return Result[Table[string, int], BridgeError].bad(BridgeError(msg: "no valid assignments"))
  Result[Table[string, int], BridgeError].good(assignments)
