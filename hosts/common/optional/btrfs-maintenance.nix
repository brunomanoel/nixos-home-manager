# Periodic btrfs balance to prevent "no space left" caused by chunk fragmentation.
# btrfs allocates space in chunks; even with free space inside chunks, new allocations
# can fail if all chunks are allocated. Balance consolidates under-utilized chunks.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Only balance chunks that are less than this % utilized.
  # 50% is conservative — avoids excessive I/O while reclaiming meaningful space.
  usageThreshold = "50";

  # Filesystems to balance: auto-detect all mounted btrfs filesystems.
  btrfsMounts = lib.filter (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems);

  mountPoints = lib.unique (map (fs: fs.mountPoint) btrfsMounts);
in
{
  systemd.services.btrfs-balance = {
    description = "Btrfs balance — consolidate under-utilized chunks";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    path = [ pkgs.btrfs-progs ];
    script = lib.concatMapStringsSep "\n" (mp: ''
      echo "Balancing ${mp} ..."
      btrfs balance start -dusage=${usageThreshold} -musage=${usageThreshold} ${mp} || true
    '') mountPoints;
  };

  systemd.timers.btrfs-balance = {
    description = "Weekly btrfs balance";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true; # run on next boot if missed
      RandomizedDelaySec = "6h"; # avoid thundering herd on multi-host setups
    };
  };

  # Also enable the built-in btrfs scrub for data integrity
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
}
