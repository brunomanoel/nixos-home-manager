# Enable the SSH daemon with hardened defaults.
# Import this only on hosts that need to accept SSH connections.
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      StreamLocalBindUnlink = "yes";
    };
  };
}
