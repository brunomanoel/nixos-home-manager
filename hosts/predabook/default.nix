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
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
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

  boot.kernel.sysctl = {
    "vm.swappiness" = 0; # não inicia swap enquanto houver page cache liberável
    "vm.vfs_cache_pressure" = 150; # prefere descartar cache a swapear
    "vm.watermark_scale_factor" = 500; # começa a reclamar com ~800MB de antecedência
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50; # ~8 GiB comprimido — absorve picos sem encher e derramar pro SSD
  };
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback # OBS Studio virtual camera requirement https://nixos.wiki/wiki/OBS_Studio
    lenovo-legion-module
    nvidia_x11
  ];

  networking.hostName = "predabook";
  networking.networkmanager.enable = true;

  # Cloudarm services via WireGuard
  networking.extraHosts = ''
    10.100.0.1 cloudarm casaos.local pelican.local
  '';

  # --- WireGuard to cloudarm ---
  # Private key stored at /etc/wireguard/private.key (not in repo)
  networking.wireguard.interfaces.CloudArm = {
    ips = [ "10.100.0.2/24" ];
    privateKeyFile = "/etc/wireguard/private.key";

    peers = [
      {
        # cloudarm
        publicKey = "pCMb0Db+WhhYqvDVqtAcat/ACxMt+FAWa1/Fmml6LlM=";
        allowedIPs = [ "10.100.0.0/24" ];
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
