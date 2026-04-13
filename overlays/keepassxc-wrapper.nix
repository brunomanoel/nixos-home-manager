# KeePassXC wrapper: adds Chromium native messaging host manifest.
# Upstream only ships the Firefox manifest. Without this, the home-manager
# programs.chromium.nativeMessagingHosts integration produces a broken symlink.
# https://github.com/nix-community/home-manager/issues/6514
{ prev }:
let
  keepassxc = prev.keepassxc;
in
prev.symlinkJoin {
  name = "keepassxc-${keepassxc.version}";
  paths = [ keepassxc ];
  inherit (keepassxc) meta version;
  passthru = keepassxc.passthru or { };
  postBuild = ''
    mkdir -p $out/etc/chromium/native-messaging-hosts
    cat > $out/etc/chromium/native-messaging-hosts/org.keepassxc.keepassxc_browser.json <<EOF
    {
      "allowed_origins": [
        "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/",
        "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
      ],
      "description": "KeePassXC integration with native messaging support",
      "name": "org.keepassxc.keepassxc_browser",
      "path": "${keepassxc}/bin/keepassxc-proxy",
      "type": "stdio"
    }
    EOF
  '';
}
