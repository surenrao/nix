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

Reading the prompt is the bottleneck on this Mac, not generating text.
MoE models with ~3B active parameters read prompts 4–5× faster than a dense
27B, so use them for parallel agents. Hybrid-attention models (Qwen3.5+
architecture) can only reuse cached prompts in 2K-token blocks.
