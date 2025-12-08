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
    192.0.2.10 gitea.home.example proget.home.example truenas.home.example
  '';

}
