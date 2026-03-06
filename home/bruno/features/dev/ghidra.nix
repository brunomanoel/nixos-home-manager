{
  lib,
  pkgs,
  config,
  ...
}:
let
  ghidra_pkg = pkgs.ghidra.withExtensions (
    exts:
    builtins.attrValues {
      inherit (exts)
        wasm
        kaiju
        ret-sync
        findcrypt
        lightkeeper
        machinelearning
        gnudisassembler
        ghidra-delinker-extension
        ghidra-golanganalyzerextension
        ghidraninja-ghidra-scripts
        ghidra-firmware-utils
        ;
    }
  );
  ghidra_dir = ".config/ghidra/${pkgs.ghidra.distroPrefix}";
in
{
  home = {
    packages = [ ghidra_pkg ];
    file = {
      "${ghidra_dir}/preferences".text = ''
        GhidraShowWhatsNew=false
        SHOW.HELP.NAVIGATION.AID=true
        SHOW_TIPS=false
        TIP_INDEX=0
        G_FILE_CHOOSER.ShowDotFiles=true
        USER_AGREEMENT=ACCEPT
        LastExtensionImportDirectory=${config.home.homeDirectory}/.config/ghidra/scripts/
        LastNewProjectDirectory=${config.home.homeDirectory}/.config/ghidra/repos/
        ViewedProjects=
        RecentProjects=
      '';
    };
  };
}
// lib.optionalAttrs pkgs.stdenv.isLinux {
  systemd.user.tmpfiles.rules = [
    # https://www.man7.org/linux/man-pages/man5/tmpfiles.d.5.html
    "d %h/${ghidra_dir} 0700 - - -"
    "L+ %h/.config/ghidra/latest - - - - %h/${ghidra_dir}"
    "d %h/.config/ghidra/scripts 0700 - - -"
    "d %h/.config/ghidra/repos 0700 - - -"
  ];
}
