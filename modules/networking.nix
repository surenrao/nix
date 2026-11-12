# Networking Configuration
# Manages network settings including hosts file entries
{ config, lib, pkgs, ... }:
let
  # Private entries (home network hosts etc.) live outside this public repo.
  # The file is read at activation time, so it is never copied into the Nix store.
  privateHosts = "/Users/${config.system.primaryUser}/.config/nix-private/hosts";

  defaultHosts = pkgs.writeText "hosts" ''
    ##
    # Host Database
    #
    # localhost is used to configure the loopback interface
    # when the system is booting.  Do not change this entry.
    ##
    127.0.0.1       localhost
    255.255.255.255 broadcasthost
    ::1             localhost
  '';
in {

  # Build /etc/hosts from the defaults above plus the private file, if present
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "Writing /etc/hosts..." >&2
    {
      cat ${defaultHosts}
      if [ -f "${privateHosts}" ]; then
        echo ""
        echo "# Private entries from ${privateHosts}"
        cat "${privateHosts}"
      fi
    } > /etc/hosts.new
    chmod 644 /etc/hosts.new
    mv -f /etc/hosts.new /etc/hosts
  '';

}
