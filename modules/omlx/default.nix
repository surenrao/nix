# oMLX (local LLM server) tuning, managed by Home Manager.
#
# oMLX owns ~/.omlx/settings.json and ~/.omlx/model_settings.json: its UI
# rewrites them, and settings.json holds the API/secret keys, which must stay
# out of git. So instead of symlinking them, each `home-manager switch`
# deep-merges the tuned values below into the live files. Keys not listed here
# (secrets, UI choices, per-model flags) are left untouched.
#
# The tuning rationale and benchmark numbers are in ./README.md.
{ config, pkgs, lib, ... }:
let
  omlxDir = "${config.home.homeDirectory}/.omlx";
  jq = "${pkgs.jq}/bin/jq";

  # merge <live file> <tracked overrides>
  mergeScript = ''
    omlx_merge() {
      live="$1"; overrides="$2"
      if [ ! -f "$live" ]; then
        if [ "$(basename "$live")" = "settings.json" ]; then
          # oMLX generates keys on first launch; don't create a partial file.
          echo "oMLX: $live not found; launch oMLX once, then re-run home-manager switch"
          return 0
        fi
        run mkdir -p "$(dirname "$live")"
        run cp "$overrides" "$live"
        run chmod 644 "$live"
        return 0
      fi
      # Compare JSON values, not bytes: oMLX writes no trailing newline.
      if ${jq} -e -n --slurpfile a "$live" --slurpfile b "$overrides" \
          '$a[0] == ($a[0] * $b[0])' >/dev/null; then
        return 0
      fi
      tmp="$(mktemp "$live.XXXXXX")"
      ${jq} --indent 2 -s '.[0] * .[1]' "$live" "$overrides" > "$tmp"
      # /usr/bin/stat: activation's PATH has GNU stat, where -f differs.
      chmod "$(/usr/bin/stat -f %Lp "$live")" "$tmp"
      run mv "$tmp" "$live"
      echo "oMLX: updated $live (restart oMLX to apply: ~/.omlx/bin/omlx restart)"
    }
    omlx_merge "${omlxDir}/settings.json" ${./settings.json}
    omlx_merge "${omlxDir}/model_settings.json" ${./model_settings.json}
  '';
in {
  home.activation.omlxSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] mergeScript;
}
