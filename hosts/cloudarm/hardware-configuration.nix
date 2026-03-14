# Placeholder — replace with output of nixos-generate-config after nixos-infect
# Oracle Cloud A1.Flex uses UEFI boot with a single block volume
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
  ];

  # TODO: Replace these with actual UUIDs from nixos-generate-config after nixos-infect
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices = [ ]; # No swap — using zram

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
