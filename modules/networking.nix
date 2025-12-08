# Networking Configuration
# Manages network settings including hosts file entries
{ config, lib, pkgs, ... }: {

  # Custom /etc/hosts entries
  environment.etc.hosts.text = ''
    ##
    # Host Database
    #
    # localhost is used to configure the loopback interface
    # when the system is booting.  Do not change this entry.
    ##
    127.0.0.1       localhost
    255.255.255.255 broadcasthost
    ::1             localhost

    # Custom entries
    192.168.68.75 gitea.rtn.surenrao.me proget.rtn.surenrao.me truenas.rtn.surenrao.me
  '';

}
