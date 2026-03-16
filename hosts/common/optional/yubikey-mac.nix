{ pkgs, ... }:
{
  # macOS handles smartcard via com.apple.ifdreader — no pcscd needed.
  # Only management tools required.
  environment.systemPackages = with pkgs; [
    yubikey-manager # ykman CLI for YubiKey management
  ];
}
