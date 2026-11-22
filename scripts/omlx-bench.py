#!/usr/bin/env python3
"""Benchmark a model on the local oMLX server, single vs parallel requests.

Each request sends a ~6K-token code file plus a short question, which is
about the size of a coding agent's system prompt + tools.

Modes:
  cold    every request has a unique prefix, so nothing is cached
          (measures raw prompt processing)
  shared  requests share the long prefix and differ only at the end,
          the way parallel agents share a system prompt; use --repeat 2
          to see warm-cache speed

Examples:
  M=Qwen3-Coder-30B-A3B-Instruct-MLX-8bit
  python3 -I scripts/omlx-bench.py $M -n 1 --mode cold
  python3 -I scripts/omlx-bench.py $M -n 3 --mode shared --repeat 2

The API key is read from ~/.omlx/settings.json and never printed.
"""

import argparse
import concurrent.futures as cf
import json
import os
import secrets
import time
import urllib.request

DEFAULT_CONTEXT = "/Applications/oMLX.app/Contents/Resources/omlx/settings.py"
DEFAULT_URL = "http://127.0.0.1:8800/v1/chat/completions"
SYSTEM = "You are a coding assistant. Be concise."
QUESTION = "List 3 concrete improvements, one line each."


def parse_args():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("model")
    ap.add_argument("-n", "--parallel", type=int, default=1)
    ap.add_argument("--mode", choices=["cold", "shared"], default="shared")
    ap.add_argument("--repeat", type=int, default=1)
    ap.add_argument("--max-tokens", type=int, default=300)
    ap.add_argument("--context-file", default=DEFAULT_CONTEXT)
    ap.add_argument("--context-chars", type=int, default=24000)
    ap.add_argument("--url", default=DEFAULT_URL)
    return ap.parse_args()


def build_prompt(mode, filler, tag):
    file_block = f"Here is a file:\n```\n{filler}\n```\n"
    if mode == "cold":
        return f"{tag} {file_block}{QUESTION}"
    return f"{file_block}{tag} {QUESTION}"


def send(args, key, prompt):
    body = {
        "model": args.model,
        "max_tokens": args.max_tokens,
        # Sent on purpose: per-model force_sampling should override it.
        "temperature": 0,
        "messages": [
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": prompt},
        ],
        "chat_template_kwargs": {"enable_thinking": False},
    }
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {key}",
    }
    req = urllib.request.Request(args.url, json.dumps(body).encode(), headers)
    start = time.time()
    resp = json.load(urllib.request.urlopen(req, timeout=900))
    usage = resp.get("usage", {})
    text = resp["choices"][0]["message"]["content"][:120]
    return (
        time.time() - start,
        usage.get("prompt_tokens"),
        usage.get("completion_tokens") or 0,
        text.replace("\n", " "),
    )


def main():
    args = parse_args()
    settings_path = os.path.expanduser("~/.omlx/settings.json")
    with open(settings_path) as f:
        key = json.load(f).get("auth", {}).get("api_key", "")
    with open(args.context_file) as f:
        filler = f.read()[: args.context_chars]

    for run in range(1, args.repeat + 1):
        nonce = secrets.token_hex(3)
        prompts = [
            build_prompt(args.mode, filler, f"[{nonce}-{i}]")
            for i in range(args.parallel)
        ]
        t0 = time.time()
        with cf.ThreadPoolExecutor(args.parallel) as ex:
            res = list(ex.map(lambda p: send(args, key, p), prompts))
        wall = time.time() - t0

        print(f"run {run}: {args.model} mode={args.mode} n={args.parallel}")
        for dt, ptok, ctok, text in res:
            print(f"  {dt:6.1f}s  prompt={ptok} gen={ctok}  | {text}")
        gen = sum(r[2] for r in res)
        print(f"  wall={wall:.1f}s  combined={gen / wall:.1f} tok/s")


if __name__ == "__main__":
    main()
