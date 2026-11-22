#!/usr/bin/env bash
# Back up GitHub repos into Gitea as pull mirrors.
#
# Gitea re-fetches each mirror on its own schedule (all branches and tags),
# so the backup keeps itself current even when this Mac is off. Re-run this
# script to pick up new GitHub repos; existing mirrors are skipped.
#
# Mirrors go into a private Gitea org (default "github-mirror"):
#   surenrao/<repo>  -> github-mirror/<repo>
#   <org>/<repo>     -> github-mirror/<org>-<repo>
# Forks and private GitHub repos are skipped (private ones would need a
# GitHub token stored in Gitea; push those to Gitea directly instead).
#
# Needs (nothing secret lives in this public repo):
#   ~/.config/nix-private/gitea.env   with  GITEA_URL=https://gitea.example
#   Keychain item "gitea-api-token"   a Gitea token with scopes
#                                     write:repository, write:organization
#     security add-generic-password -a "$USER" -s gitea-api-token -w
#     (prompts for the token; nothing lands in shell history)
#   gh logged in (to list repos), curl, jq
#
# Usage: scripts/gitea-mirror-github.sh [--dry-run]
set -euo pipefail

GITHUB_OWNERS=(surenrao tv-watchlist distro-tailor)
MIRROR_ORG="github-mirror"
MIRROR_INTERVAL="8h0m0s"

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

env_file="$HOME/.config/nix-private/gitea.env"
[ -f "$env_file" ] && . "$env_file"
: "${GITEA_URL:?set GITEA_URL in $env_file}"
GITEA_URL="${GITEA_URL%/}"

if ! token="$(security find-generic-password -a "$USER" -s gitea-api-token -w 2>/dev/null)"; then
  echo "No Keychain item 'gitea-api-token'. Create one with:" >&2
  echo "  security add-generic-password -a \"\$USER\" -s gitea-api-token -w" >&2
  exit 1
fi

gitea() { # gitea METHOD PATH [JSON] -> prints body, returns 0 on 2xx
  local method="$1" path="$2" data="${3:-}" out code
  out="$(mktemp)"
  code="$(curl -sS -o "$out" -w '%{http_code}' -X "$method" \
    -H "Authorization: token $token" -H "Content-Type: application/json" \
    ${data:+--data "$data"} "$GITEA_URL/api/v1$path")"
  cat "$out"; rm -f "$out"
  [[ "$code" == 2* ]]
}

me="$(gitea GET /user | jq -r .login)" || { echo "Gitea token rejected" >&2; exit 1; }
echo "Gitea user: $me, mirrors go to org '$MIRROR_ORG'"

if ! gitea GET "/orgs/$MIRROR_ORG" >/dev/null 2>&1; then
  if [ "$dry_run" = 1 ]; then
    echo "would create private org $MIRROR_ORG"
  else
    gitea POST /orgs "$(jq -nc --arg n "$MIRROR_ORG" \
      '{username: $n, visibility: "private",
        description: "Pull mirrors of GitHub repos (backup)"}')" >/dev/null
    echo "created private org $MIRROR_ORG"
  fi
fi

created=0 skipped=0 failed=0
for owner in "${GITHUB_OWNERS[@]}"; do
  if [ "$owner" = "$(gh api user --jq .login)" ]; then
    list="users/$owner/repos?type=owner&per_page=100"
  else
    list="orgs/$owner/repos?per_page=100"
  fi
  while IFS=$'\t' read -r full name desc; do
    target="$name"
    [ "$owner" != "surenrao" ] && target="$owner-$name"
    if gitea GET "/repos/$MIRROR_ORG/$target" >/dev/null 2>&1; then
      skipped=$((skipped + 1)); continue
    fi
    if [ "$dry_run" = 1 ]; then
      echo "would mirror $full -> $MIRROR_ORG/$target"; continue
    fi
    body="$(jq -nc --arg url "https://github.com/$full.git" --arg org "$MIRROR_ORG" \
      --arg name "$target" --arg desc "Mirror of github.com/$full. $desc" \
      --arg iv "$MIRROR_INTERVAL" \
      '{clone_addr: $url, repo_owner: $org, repo_name: $name, service: "github",
        mirror: true, mirror_interval: $iv, private: true,
        description: ($desc | .[0:255])}')"
    if gitea POST /repos/migrate "$body" >/dev/null; then
      echo "mirrored $full -> $MIRROR_ORG/$target"; created=$((created + 1))
    else
      echo "FAILED  $full" >&2; failed=$((failed + 1))
    fi
  done < <(gh api --paginate "$list" \
    --jq '.[] | select(.fork | not) | select(.private | not)
          | [.full_name, .name, (.description // "")] | @tsv')
done

echo "done: $created created, $skipped already mirrored, $failed failed"
[ "$failed" = 0 ]
