# Claude Code status line: model and context window usage, e.g.
#   Qwen3.6-35B-A3B-6bit · ctx 52K/128K (41%)
# Claude Code pipes session JSON on stdin and shows the first line printed.
# Green under 50%, yellow under 75%, red after (auto-compact is near).
#
# Window size: local models launched by `omlx launch claude` (see
# claude-local.sh) get CLAUDE_CODE_MAX_CONTEXT_TOKENS, which this process
# inherits; prefer it over the JSON's size so the total matches the model.

input="$(cat)"
IFS=$'\t' read -r model used size <<<"$(jq -r '[
  (.model.display_name // .model.id // "?"),
  (.context_window.total_input_tokens // 0),
  (.context_window.context_window_size // 0)
] | @tsv' <<<"$input")"

size="${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-$size}"

# K = 1024 tokens, so a 131,072-token window reads 128K as configured.
k() { echo "$(( ($1 + 512) / 1024 ))K"; }

if [ "${size:-0}" -gt 0 ]; then
  pct=$(( used * 100 / size ))
  if [ "$pct" -ge 75 ]; then color=31
  elif [ "$pct" -ge 50 ]; then color=33
  else color=32; fi
  printf '%s · \033[%smctx %s/%s (%s%%)\033[0m\n' \
    "$model" "$color" "$(k "$used")" "$(k "$size")" "$pct"
else
  printf '%s\n' "$model"
fi
