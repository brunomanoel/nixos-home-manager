# sops-nix — declarative secret provisioning.
# Age keys derived from SSH host keys (ed25519).
# Hosts without sshd must set services.openssh.generateHostKeys = true
# separately (available on nixpkgs-unstable only).
{
  inputs,
  config,
  ...
}:
let
  isEd25519 = k: k.type == "ed25519";
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  sops.age.sshKeyPaths = map (k: k.path) keys;
}
