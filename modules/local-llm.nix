# Local LLM Inference Tuning
# System settings for running local models (oMLX) on the M4 Max / 64GB.
{ ... }:
let
  # How much unified memory the GPU may wire, in MB. macOS defaults to ~75%
  # (about 52GB here); 57344 = 56GB leaves ~8GB for macOS and apps.
  # oMLX's memory guard reads this value to size its model + KV-cache ceiling.
  gpuWiredLimitMb = 57344;
in {
  # iogpu.wired_limit_mb resets on every boot, so set it from a launchd daemon.
  # RunAtLoad also fires when darwin-rebuild (re)loads the daemon, so a change
  # here takes effect on the next rebuild without a reboot.
  launchd.daemons.iogpu-wired-limit = {
    serviceConfig = {
      Label = "org.nixos.iogpu-wired-limit";
      ProgramArguments = [
        "/usr/sbin/sysctl"
        "iogpu.wired_limit_mb=${toString gpuWiredLimitMb}"
      ];
      RunAtLoad = true;
      StandardOutPath = "/var/log/iogpu-wired-limit.log";
      StandardErrorPath = "/var/log/iogpu-wired-limit.log";
    };
  };
}
