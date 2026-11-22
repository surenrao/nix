# oMLX tuning

oMLX (local LLM server, port 8800) is installed by hand from
https://github.com/jundot/omlx/releases (see `manual-installs.txt`).
Only its tuning lives here.

## How it's applied

`default.nix` adds a Home Manager activation step. Each `home-manager switch`
deep-merges `settings.json` and `model_settings.json` from this folder into
`~/.omlx/`. Anything not listed here, including the API and secret keys, is left
alone. Restart oMLX after a change: `~/.omlx/bin/omlx restart`.

The GPU memory limit oMLX relies on (`iogpu.wired_limit_mb`) is set
system-wide in `../local-llm.nix`.

## Why these values

- **Forced per-model sampling**: some agent clients send `temperature: 0`,
  which makes Qwen models loop. `force_sampling` makes oMLX use Qwen's
  recommended values whatever the client sends.
- **Context**: 64K by default, 128K for Qwen3.8-27B. Agent system prompts and
  tool lists alone are 10–15K tokens.
- **`prefill_priority: context`**: under memory pressure, finish long prompts
  slowly instead of refusing them.
- **`chunked_prefill: true`**: a big prompt from one agent doesn't stall the
  others mid-answer. Measured slightly faster for 3 parallel requests.
- **SSD cache capped at 100GB**: the old "auto" setting let it grow to ~240GB.

## Benchmarks (M4 Max 64GB, oMLX 0.8.2, ~6K-token prompt)

Run with `scripts/omlx-bench.py`.

| | Qwen3-Coder-30B-A3B 8-bit (MoE) | Qwen3.8-27B 4-bit (dense) |
|---|---|---|
| 1 request, nothing cached | ~6s | ~27–32s |
| 3 parallel, nothing cached | ~17s | 63–104s |
| 3 parallel, shared prefix cached | ~3.6s each, ~69 tok/s combined | ~38s |

### Qwen3.6-35B-A3B 6-bit vs Qwen3-Coder-30B-A3B 8-bit (2026-11-22)

| | Qwen3.6-35B-A3B 6-bit (27GB) | Qwen3-Coder-30B-A3B 8-bit (30GB) |
|---|---|---|
| 1 request, nothing cached | 3.7s | 4.7s |
| 3 parallel, nothing cached | 11.9s | 15.7s |
| 3 parallel, shared prefix cached | 5.4s | 3.2s |
| Tool calls correct (12 agent-style prompts) | 11/12 | 10/12 |
| `parse_duration` task passes its tests | 4/5 | 4/5 |
| Thinking mode | yes | no |
| Context set in oMLX | 128K | 64K |

The tool-call "misses" were mostly reading README.md before editing it, which
is reasonable agent behaviour. Small samples, so quality is effectively a tie.
Qwen3.6 reads cold prompts faster and supports longer context cheaply
(hybrid attention keeps the KV cache small). Coder reuses cached prefixes
in 256-token blocks instead of 2K, so it's quicker on repeated agent turns.
Run one model at a time for parallel agents: both together exceed the
memory ceiling and oMLX would swap them in and out.

### Agent test: local Claude Code on 6 Exercism tasks (2026-11-22)

Mini Aider-Polyglot run: Claude Code 2.1.330 via `omlx launch claude`,
6 of the hardest Python exercises (forth, react, pov, book-store, two-bucket,
sgf-parsing). Each task got instructions, stub and tests, max 40 turns and
15 min. Scored on the original test file.

| | Qwen3.6-35B-A3B 6-bit | Qwen3-Coder-30B-A3B 8-bit |
|---|---|---|
| Solved | **6/6** (~20 min total, 43s–8 min each) | stopped early: forth 49/54 after ~10 min (Qwen3.6: 43s) |
| Test files edited | none | none |

**Qwen3.6-35B-A3B is the default model.** These exercises are public, so they
may be in the models' training data. Treat this as "the agent loop works"
rather than a measure of skill on unseen problems.

Reading the prompt is the bottleneck on this Mac, not generating text.
MoE models with ~3B active parameters read prompts 4–5× faster than a dense
27B, so use them for parallel agents. Hybrid-attention models (Qwen3.5+
architecture) can only reuse cached prompts in 2K-token blocks.
