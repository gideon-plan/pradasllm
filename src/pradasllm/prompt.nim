## prompt.nim -- Format pradas problem as LLM prompt.
{.experimental: "strict_funcs".}
import std/strutils
type
  ProblemDesc* = object
    name*: string
    entities*: seq[string]
    variables*: seq[string]
    constraints*: seq[string]
proc format_prompt*(desc: ProblemDesc): string =
  var lines: seq[string]
  lines.add("Solve this constraint optimization problem:")
  lines.add("Problem: " & desc.name)
  lines.add("Entities: " & desc.entities.join(", "))
  lines.add("Variables: " & desc.variables.join(", "))
  lines.add("Constraints:")
  for c in desc.constraints: lines.add("  - " & c)
  lines.add("Respond with variable=value assignments, one per line.")
  lines.join("\n")
