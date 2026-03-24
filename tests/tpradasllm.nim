{.experimental: "strict_funcs".}
import std/[unittest, strutils, tables]
import pradasllm
suite "prompt":
  test "format prompt":
    let desc = ProblemDesc(name: "nqueens", entities: @["Q1","Q2"],
                           variables: @["row"], constraints: @["no same row"])
    let p = format_prompt(desc)
    check p.contains("nqueens")
    check p.contains("no same row")
suite "parse":
  test "parse assignments":
    let r = parse_assignments("Q1=0\nQ2=3\n")
    check r.is_good
    check r.val["Q1"] == 0
    check r.val["Q2"] == 3
  test "empty response fails":
    let r = parse_assignments("")
    check r.is_bad
suite "warmstart":
  test "apply warmstart":
    var applied: seq[string]
    let mock_apply: ApplyFn = proc(v: string, val: int): Result[void, BridgeError] {.raises: [].} =
      applied.add(v); Result[void, BridgeError](ok: true)
    let r = apply_warmstart({"x": 1, "y": 2}.toTable, mock_apply)
    check r.is_good
    check r.val.applied == 2
suite "session":
  test "solve with hint":
    let mock_inf: InferenceFn = proc(p: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("x=1\ny=2")
    let mock_apply: ApplyFn = proc(v: string, val: int): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    let mock_solve: SolveFn = proc(): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("solved")
    var s = new_session(mock_inf, mock_apply, mock_solve)
    let desc = ProblemDesc(name: "test", entities: @["a"], variables: @["x"])
    let r = s.solve_with_hint(desc)
    check r.is_good
    check r.val == "solved"
    check s.warm_starts == 1
