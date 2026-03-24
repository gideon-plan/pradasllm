## warmstart.nim -- Inject assignments into PlanningSolution.
{.experimental: "strict_funcs".}
import std/tables
import lattice
type
  WarmStartResult* = object
    applied*: int
    skipped*: int
  ApplyFn* = proc(variable: string, value: int): Result[void, BridgeError] {.raises: [].}
proc apply_warmstart*(assignments: Table[string, int],
                      apply_fn: ApplyFn): Result[WarmStartResult, BridgeError] =
  var ws: WarmStartResult
  for variable, value in assignments:
    let r = apply_fn(variable, value)
    if r.is_good: inc ws.applied
    else: inc ws.skipped
  Result[WarmStartResult, BridgeError].good(ws)
