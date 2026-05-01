# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-laptop
    ./hardware-configuration.nix
    ./custom-hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    ../common/global
    ../common/global/desktop.nix
    ../common/users/bruno
    ../common/optional/gnome.nix
    ../common/optional/hyprland.nix
    ../common/optional/docker.nix
    # ../common/optional/virtualbox.nix # disabled: VirtualBox modules incompatible with kernel 6.19+
    ../common/optional/gaming.nix
    ../common/optional/ai-services.nix
    ../common/optional/yubikey.nix
    ../common/optional/btrfs-maintenance.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.rebootForBitlocker = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.plymouth = {
    enable = true;
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "darth_vader" ]; })
    ];
    theme = "darth_vader";
  };

  boot.kernelParams = [
    "i915.enable_fbc=1"
    "i915.enable_psr=0"
    # "intel_idle.max_cstate=1" # In case your laptop hangs randomly
    "resume=UUID=8e09cba4-9bd2-4a99-b46a-6fbcb480a742" # hibernation target: /dev/sda1
  ];

  # VM tuning calibrated for 64 GiB RAM. Previous values targeted 16 GiB and
  # scaled poorly when RAM grew (percentual settings became absolute giants).
  boot.kernel.sysctl = {
    # 0 means "prefer OOM kill over swap" since kernel 5.8; 1 keeps the original
    # intent ("swap only as last resort, but before OOM").
    "vm.swappiness" = 1;
    # With 64 GiB free metadata cache is cheap; favor keeping inode/dentry cache
    # over page cache to speed up filesystem-heavy operations (git, find, builds).
    "vm.vfs_cache_pressure" = 50;
    # 125 = 1.25% of RAM ≈ 800 MiB of headroom before kswapd kicks in,
    # matching the original ~800 MiB intent on 16 GiB.
    "vm.watermark_scale_factor" = 125;
    # Use absolute byte limits instead of percentages: with 64 GiB RAM, the
    # default 10%/5% would allow up to ~6 GiB of dirty pages, causing long
    # writeback stalls on SATA SSD and large data loss on crash. 1 GiB / 256 MiB
    # gives predictable ~2s stalls and bounded crash exposure.
    "vm.dirty_bytes" = 1073741824; # 1 GiB
    "vm.dirty_background_bytes" = 268435456; # 256 MiB
  };

  zramSwap = {
    enable = true;
    # 10% of RAM ≈ 6 GiB. With 64 GiB physical RAM and ~30 GiB typical usage,
    # zram is mostly idle; this keeps a modest compressed buffer for spikes
    # without wasting half of RAM on a swap reserve we rarely need.
    memoryPercent = 10;
  };

  # Mount /tmp as tmpfs (RAM-backed). Speeds up build/temp-heavy workloads and
  # avoids wear on /. NOTE: tmpfs contents live in RAM and are therefore part
  # of the hibernation image; large files in /tmp increase the hibernation
  # image size and may push it over the swap partition limit.
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;

  # Nix build parallelism tuned for predabook (12 threads, 64 GiB RAM).
  # Profile: many small builds with occasional large ones. 6 jobs × 2 cores
  # = 12 threads (no oversubscription per upstream tuning docs), favoring
  # parallelism between derivations over per-build core count.
  nix.settings = {
    max-jobs = 6;
    cores = 2;
  };

  # Intel Thermal Daemon. Reads OEM DPTF tables (Lenovo populates rich thermal
  # data for this gaming laptop) and acts preventively on temperature trends
  # via P-state and RAPL, reducing throttling spikes during sustained loads
  # (long builds, gaming). No conflict with power-profiles-daemon or intel_pstate.
  services.thermald.enable = true;

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback # OBS Studio virtual camera requirement https://nixos.wiki/wiki/OBS_Studio
    lenovo-legion-module
    nvidia_x11
  ];

  networking.hostName = "predabook";
  networking.networkmanager.enable = true;

  # Cloudarm services via WireGuard
  # casaos.local aponta direto pro container Incus (10.200.0.166) pra permitir
  # acesso a apps CasaOS em qualquer porta (casaos.local:8100, etc). Requer rota
  # pra subnet 10.200.0.0/24 via wg0 (allowedIPs abaixo).
  networking.extraHosts = ''
    10.100.0.1 cloudarm pelican.local thingsboard.local nextcloud.local paperless.local n8n.local uptime.local beszel.local
    10.200.0.166 casaos.local
  '';

  # --- Host key generation (no sshd, only for sops-nix age derivation) ---
  services.openssh.generateHostKeys = true;

  # --- Secrets (sops-nix) ---
  sops.secrets.wireguard-private-key.sopsFile = ./secrets.yaml;

  # --- WireGuard to cloudarm ---
  networking.wireguard.interfaces.CloudArm = {
    ips = [ "10.100.0.2/24" ];
    privateKeyFile = config.sops.secrets.wireguard-private-key.path;

    peers = [
      {
        # cloudarm
        publicKey = "pCMb0Db+WhhYqvDVqtAcat/ACxMt+FAWa1/Fmml6LlM=";
        # 10.200.0.0/24 = subnet Incus do cloudarm (containers CasaOS)
        allowedIPs = [
          "10.100.0.0/24"
          "10.200.0.0/24"
        ];
        endpoint = "137.131.233.96:51820";
        persistentKeepalive = 25;
      }
    ];
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  powerManagement.enable = true;

  # For electron apps to work on wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring TUI
    gpustat # GPU status one-liner
    libnotify # notify-send para opencode-notifier
    dmidecode # SMBIOS/DIMM info
    hardinfo2 # hardware info + benchmarks GUI
  ];

  programs.kdeconnect.enable = true;

  # Allow dynamically linked executables (e.g. vscode extensions, .NET, claude-code native binary)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl
    icu
    libxml2
    libz
    glib
    nss
    nspr
    dbus
    atk
    cups
    libdrm
    gtk3
    pango
    cairo
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    mesa
    expat
    libxkbcommon
    alsa-lib
  ];

}
