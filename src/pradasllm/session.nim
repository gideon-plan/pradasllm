## session.nim -- Combined prompt -> infer -> parse -> solve session.
{.experimental: "strict_funcs".}

import lattice, prompt, parse, warmstart
type
  InferenceFn* = proc(prompt_text: string): Result[string, BridgeError] {.raises: [].}
  SolveFn* = proc(): Result[string, BridgeError] {.raises: [].}
  PradasLlmSession* = object
    inference_fn*: InferenceFn
    apply_fn*: ApplyFn
    solve_fn*: SolveFn
    warm_starts*: int
proc new_session*(inf_fn: InferenceFn, apply_fn: ApplyFn,
                  solve_fn: SolveFn): PradasLlmSession =
  PradasLlmSession(inference_fn: inf_fn, apply_fn: apply_fn, solve_fn: solve_fn)
proc solve_with_hint*(s: var PradasLlmSession,
                      desc: ProblemDesc): Result[string, BridgeError] =
  let prompt_text = format_prompt(desc)
  let response = s.inference_fn(prompt_text)
  if response.is_good:
    let assignments = parse_assignments(response.val)
    if assignments.is_good:
      discard apply_warmstart(assignments.val, s.apply_fn)
      inc s.warm_starts
  s.solve_fn()
