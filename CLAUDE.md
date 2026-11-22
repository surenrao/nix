# nix: notes for AI assistants

macOS system config for the M4 Max (64GB) "m4max": nix-darwin flake plus a
standalone Home Manager config. ARCHITECTURE.md describes each module.

## Structure

- `flake.nix` → `darwinConfigurations.m4max`, modules in `modules/*.nix`.
- Home Manager is standalone: `~/.config/home-manager/home.nix` is a symlink
  to `modules/home.nix`; relative imports in it (e.g. `./omlx`) work.
- New files must be `git add`ed before a flake build can see them.

## Commands

- Build without applying (no sudo):
  `nix build .#darwinConfigurations.m4max.system --no-link` and, from a temp
  dir (it creates `./result`), `home-manager build`.
- Apply: `./rebuild-system.sh` (sudo darwin-rebuild switch, then
  home-manager switch). Updates: `./update-system.sh` (flake update + rebuild).
- Applying changes the live system, so leave it to the user unless asked.
- `check-drift.sh` lists software installed outside the config.

## Patterns to follow

- **Self-updating apps**: Nix only installs them when missing; their own
  updater handles updates.
  - GUI apps with updaters: Homebrew casks in `modules/homebrew.nix`
    (`onActivation.upgrade = false`, `autoUpdate = false`). Check the cask
    has `auto_updates: true`; `claude-code`'s cask does not, so it isn't one.
  - CLIs with their own installer: a `home.activation` step that runs the
    installer only if the binary is absent (see Claude Code in `home.nix`).
- **Homebrew `cleanup = "zap"`**: anything not listed is removed on rebuild.
  Run `check-drift.sh` first; `rebuild-system.sh` does.
- **App config that the app also writes** (and may hold secrets): don't
  symlink it. Track only the tuned keys and deep-merge them with `jq` on
  `home-manager switch` (see `modules/omlx/default.nix`).
- **Private data** (e.g. /etc/hosts entries) stays outside the repo in
  `~/.config/nix-private/`.

## Local LLM setup

- oMLX (manual install, see `manual-installs.txt`), server on port 8800.
  Tuning: `modules/omlx/` (settings + per-model sampling, benchmarks in its
  README). Default model: Qwen3.6-35B-A3B 6-bit.
- `modules/local-llm.nix`: launchd daemon sets `iogpu.wired_limit_mb=57344`
  (56GB GPU memory) at boot.
- `scripts/omlx-bench.py`: single vs parallel speed benchmark.
- Local Claude Code: `omlx launch claude --model <model>`.

## Backups to the NAS (Gitea)

- `scripts/gitea-mirror-github.sh`: creates Gitea pull mirrors of all
  non-fork public GitHub repos (surenrao, tv-watchlist, distro-tailor) in
  the private org `github-mirror`; Gitea re-syncs every 8h. Re-run to add
  new repos (existing ones are skipped); `--dry-run` previews.
- It reads `GITEA_URL` from `~/.config/nix-private/gitea.env` and the token
  from Keychain item `gitea-api-token`. This repo is public on GitHub, so
  never put hostnames or tokens in it.
- Gitea has push-to-create disabled: create a repo first (web UI or API),
  then push.

## Gotchas

- Pre-commit runs black (88 cols) and flake8 (79 cols). Keep Python lines
  under 80 so both pass without black reformatting.
- `python3 -I` drops the current directory from `sys.path`; don't use it to
  run tests that import local modules.
- The desktop Claude app sets `DISABLE_AUTOUPDATER=1` in its own
  environment; that doesn't apply to the user's terminal.
- Commits: conventional style (`feat(scope): ...`, `refactor: ...`).
