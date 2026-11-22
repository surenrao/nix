#!/usr/bin/env bash
# Run Claude Code against the local oMLX server instead of Anthropic.
#
# Works on the current directory, so run it from the project you want to
# work in:   ~/nix/claude-local.sh
# Starts the oMLX server if it isn't up. Your normal `claude` is unaffected:
# the local endpoint is only set for this session.
#
# Usage:
#   claude-local.sh                           default model (DEFAULT_MODEL)
#   claude-local.sh --model Qwen3.8-27B-4bit  another model for this run
#   claude-local.sh --haiku <model> ...       any other `omlx launch` option
#
# Changing the model
#   For one run:   pass --model <name> (it overrides the default).
#   Permanently:   edit DEFAULT_MODEL below.
#   Pick from a list instead: run `omlx launch claude` with no --model.
#   Names are the folder names in ~/.omlx/models/<publisher>/:
#     ls ~/.omlx/models/*/
#
#   Installed models (M4 Max 64GB; benchmarks in modules/omlx/README.md):
#     Qwen3.6-35B-A3B-6bit       Default. MoE, fast; best agent in our
#                                test (solved 6/6 tasks).
#     Qwen3.8-27B-4bit           Dense; can reason better, but reads long
#                                prompts ~4-5x slower (slow first reply).
#     Qwen3-Coder-30B-A3B-Instruct-MLX-8bit
#                                Older; got stuck in the agent test.
#   Sampling and context per model live in ~/.omlx/model_settings.json,
#   tracked in modules/omlx/model_settings.json.
#
# Claude Code's model tiers
#   Claude Code asks for an Opus, Sonnet or Haiku model depending on the
#   task (e.g. Haiku for quick background work). By default all tiers use
#   --model. To send a tier elsewhere, add --opus, --sonnet or --haiku:
#     claude-local.sh --haiku Qwen3.6-35B-A3B-6bit --opus Qwen3.8-27B-4bit
#
# Limits to expect
#   - Context: 128K tokens for Qwen3.6 and Qwen3.8, 64K for Qwen3-Coder
#     (and for any model without its own setting).
#   - The first reply is slow while Claude Code's long system prompt is
#     processed; later turns reuse oMLX's prompt cache.
#   - The GPU is shared with anything else using it (e.g. ComfyUI): a
#     render and the local model slow each other down.
#   - Fine for routine edits and tests; noticeably weaker than Claude on
#     hard multi-file work. Exit and run plain `claude` for that.
set -euo pipefail

DEFAULT_MODEL="Qwen3.6-35B-A3B-6bit"

OMLX="$HOME/.omlx/bin/omlx"
[ -x "$OMLX" ] || OMLX="$(command -v omlx)" || {
  echo "oMLX not found; install it (see manual-installs.txt)." >&2
  exit 1
}

port="$(jq -r '.server.port // 8800' "$HOME/.omlx/settings.json" 2>/dev/null || echo 8800)"
health="http://127.0.0.1:${port}/health"

if ! curl -fsS -o /dev/null "$health" 2>/dev/null; then
  echo "oMLX server not running on port $port; starting it..."
  "$OMLX" start >/dev/null
  for _ in $(seq 60); do
    curl -fsS -o /dev/null "$health" 2>/dev/null && break
    sleep 1
  done
  curl -fsS -o /dev/null "$health" 2>/dev/null || {
    echo "oMLX didn't come up within 60s; check: $OMLX diagnose" >&2
    exit 1
  }
fi

# The default goes first so a --model in "$@" overrides it (last one wins).
exec "$OMLX" launch claude --model "$DEFAULT_MODEL" "$@"
