{ pkgs, ... }:
{
  # pcscd required for YubiKey smartcard (CCID/OpenPGP) support on Linux.
  # Not needed on macOS (handled by com.apple.ifdreader) or cloudarm (no physical YubiKey).
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-manager # ykman CLI for YubiKey management
  ];
}
