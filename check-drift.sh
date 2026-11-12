#!/bin/bash

# Drift Check Script
# Lists software installed outside the Nix config so it can be added to it
# (or knowingly dropped). Homebrew extras are removed by the next rebuild
# because homebrew.onActivation.cleanup = "zap".

FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST="m4max"
BREW="/opt/homebrew/bin/brew"

# Packages the Nix installer puts in the user profile, plus home-manager's own
nix_profile_ignore="home-manager-path nix nss-cacert"

config_list() {
  nix eval --raw "$FLAKE_DIR#darwinConfigurations.$HOST.config.homebrew.$1" \
    --apply 'xs: builtins.concatStringsSep "\n" (map (x: x.name) xs)' 2>/dev/null
}

# Print lines of $1 that are not in $2
missing_from() {
  comm -23 <(printf '%s\n' "$1" | sed '/^$/d' | sort -u) \
           <(printf '%s\n' "$2" | sed '/^$/d' | sort -u)
}

brew_extra_formulae=""
brew_extra_casks=""
if [ -x "$BREW" ]; then
  # Short names, so tap formulae (user/tap/foo) match config entries either way
  installed_formulae="$("$BREW" leaves --installed-on-request 2>/dev/null)"
  installed_casks="$("$BREW" list --cask -1 2>/dev/null)"
  configured_formulae="$(config_list brews | sed 's#.*/##')"
  configured_casks="$(config_list casks | sed 's#.*/##')"

  brew_extra_formulae="$(missing_from "$(printf '%s\n' "$installed_formulae" | sed 's#.*/##')" "$configured_formulae")"
  brew_extra_casks="$(missing_from "$(printf '%s\n' "$installed_casks" | sed 's#.*/##')" "$configured_casks")"
fi

nix_profile_extras() {
  nix-env -q 2>/dev/null | sed -E 's/-[0-9][^-]*$//' | while read -r pkg; do
    case " $nix_profile_ignore " in
      *" $pkg "*) ;;
      *) echo "$pkg" ;;
    esac
  done
}

nix_extra="$(nix_profile_extras)"

# Everything else (npm, cargo, pip, apps...) is compared with the committed snapshot
snapshot_file="$FLAKE_DIR/manual-installs.txt"
manual_now="$("$FLAKE_DIR/snapshot-manual-installs.sh" --print)"
manual_snapshot="$(grep -v '^#' "$snapshot_file" 2>/dev/null)"
manual_new="$(missing_from "$manual_now" "$manual_snapshot")"
manual_gone="$(missing_from "$manual_snapshot" "$manual_now")"

if [ -z "$brew_extra_formulae$brew_extra_casks$nix_extra$manual_new$manual_gone" ]; then
  echo "✅ Everything installed is in the Nix config or manual-installs.txt."
  exit 0
fi

echo "⚠️  Installed software not covered by the Nix config:"
if [ -n "$brew_extra_formulae$brew_extra_casks" ]; then
  echo ""
  echo "  Homebrew (WILL BE REMOVED by the next rebuild; add to modules/homebrew.nix to keep):"
  [ -n "$brew_extra_formulae" ] && printf '    brew: %s\n' $brew_extra_formulae
  [ -n "$brew_extra_casks" ] && printf '    cask: %s\n' $brew_extra_casks
fi
if [ -n "$nix_extra" ]; then
  echo ""
  echo "  Nix user profile (kept, but not restored on a new machine; add to modules/packages.nix):"
  printf '    %s\n' $nix_extra
fi
if [ -n "$manual_new" ]; then
  echo ""
  echo "  New since last snapshot (consider moving to Nix/Homebrew, or run ./snapshot-manual-installs.sh):"
  printf '%s\n' "$manual_new" | sed 's/^/    /'
fi
if [ -n "$manual_gone" ]; then
  echo ""
  echo "  In snapshot but not installed (reinstall, or run ./snapshot-manual-installs.sh):"
  printf '%s\n' "$manual_gone" | sed 's/^/    /'
fi

# Only Homebrew extras are destructive; the rest is informational
[ -z "$brew_extra_formulae$brew_extra_casks" ]
