# Claude Code CLI settings, managed by Home Manager.
#
# Claude Code also writes ~/.claude/settings.json (e.g. /config changes), so
# it isn't symlinked: each `home-manager switch` deep-merges only the keys
# below into it (same approach as ../omlx).
#
# Status line: model and context usage (see ./statusline.sh).
{ config, pkgs, lib, ... }:
let
  jq = "${pkgs.jq}/bin/jq";
  settingsFile = "${config.home.homeDirectory}/.claude/settings.json";

  statusline = pkgs.writeShellScript "claude-statusline" ''
    export PATH=${pkgs.jq}/bin:$PATH
    ${builtins.readFile ./statusline.sh}
  '';

  overrides = pkgs.writeText "claude-settings-overrides.json" (builtins.toJSON {
    statusLine = {
      type = "command";
      command = "${config.home.homeDirectory}/.claude/statusline.sh";
      padding = 0;
    };
  });
in {
  home.file.".claude/statusline.sh".source = statusline;

  home.activation.claudeCodeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      live="${settingsFile}"
      if [ ! -f "$live" ]; then
        run mkdir -p "$(dirname "$live")"
        run cp ${overrides} "$live"
        run chmod 644 "$live"
      elif ! ${jq} -e -n --slurpfile a "$live" --slurpfile b ${overrides} \
          '$a[0] == ($a[0] * $b[0])' >/dev/null; then
        tmp="$(mktemp "$live.XXXXXX")"
        ${jq} --indent 2 -s '.[0] * .[1]' "$live" ${overrides} > "$tmp"
        chmod "$(/usr/bin/stat -f %Lp "$live")" "$tmp"
        run mv "$tmp" "$live"
        echo "Claude Code: updated $live"
      fi
    '';
}
