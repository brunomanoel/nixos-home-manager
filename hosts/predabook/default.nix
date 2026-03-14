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

    ../common/users/bruno
    ../common/global
    ../common/optional/gnome.nix
    ../common/optional/hyprland.nix
    ../common/optional/docker.nix
    # ../common/optional/virtualbox.nix # disabled: VirtualBox modules incompatible with kernel 6.19+
    ../common/optional/gaming.nix
    ../common/optional/ai-services.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.kernelParams = [
    "i915.enable_fbc=1"
    "i915.enable_psr=0"
    # "intel_idle.max_cstate=1" # In case your laptop hangs randomly
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 150; # zram-aware: favors zram over disk, but less aggressive than 180
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 75; # ~12GB compressed — safe without disk swap (OOM kills vs freeze)
  };
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback # OBS Studio virtual camera requirement https://nixos.wiki/wiki/OBS_Studio
    lenovo-legion-module
    nvidia_x11
  ];

  networking.hostName = "predabook";
  # Enable networking
  networking.networkmanager.enable = true;
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
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
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

  specialisation = {
    xanmod.configuration = {
      system.nixos.tags = [ "xanmod" ];
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod_latest;
    };
    latest.configuration = {
      system.nixos.tags = [ "latest" ];
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    };
  };
}
