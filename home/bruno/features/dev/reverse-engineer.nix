{pkgs, ...}: {
  imports = [
    # ./ghidra.nix
  ];

  home.packages = with pkgs; [
    elf-info
    elfcat
    pwntools
  ];
}
