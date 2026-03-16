{ pkgs, ... }:
{
  # pcscd required for YubiKey smartcard (CCID/OpenPGP) support on Linux.
  # Not needed on macOS (handled by com.apple.ifdreader) or cloudarm (no physical YubiKey).
  services.pcscd.enable = true;

  # udev rules for YubiKey USB access without root
  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    gnupg # GPG — required for YubiKey OpenPGP operations
    yubikey-manager # ykman CLI for YubiKey management
    yubikey-personalization # udev rules + personalization tool
    yubico-piv-tool # PIV tool + libykcs11.so for PKCS#11
  ];
}
