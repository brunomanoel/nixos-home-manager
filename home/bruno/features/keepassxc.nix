{ pkgs, lib, ... }:
{
  xdg.autostart.enable = lib.mkIf pkgs.stdenv.isLinux true;

  programs.keepassxc = {
    enable = true;
    autostart = lib.mkIf pkgs.stdenv.isLinux true;
    settings = {
      General = {
        AutoSaveAfterEveryChange = true;
        AutoReloadOnChange = true;
        AutoSaveOnExit = true;
        OpenPreviousDatabasesOnStartup = true;
        MinimizeAfterUnlock = true;
      };

      Security = {
        ClearClipboard = true;
        ClearClipboardTimeout = 10;
        LockDatabaseIdle = false;
        LockDatabaseScreenLock = true;
        LockDatabaseOnUserSwitch = true;
      };

      Browser = {
        Enabled = true;
        SearchInAllDatabases = true;
        UpdateBinaryPath = false; # home-manager manages native messaging manifests
        ChromiumSupport = true;
        FirefoxSupport = true;
      };

      SSHAgent = {
        Enabled = true;
        UseOpenSSH = lib.mkIf pkgs.stdenv.isLinux true;
      };

      FdoSecrets = lib.mkIf pkgs.stdenv.isLinux {
        Enabled = true;
        ShowNotification = true;
        ConfirmAccessItem = true;
      };

      GUI = {
        ApplicationTheme = "dark";
        ShowTrayIcon = true;
        MinimizeToTray = true;
        MinimizeOnClose = true;
        MinimizeOnStartup = true;
        HidePasswords = true;
        CompactMode = true;
        CheckForUpdates = false; # managed by Nix
      };
    };
  };

  programs.git-credential-keepassxc = {
    enable = true;
    # hosts = [ "https://github.com" ];
    # Bug in home-manager: misplaced parenthesis in module breaks with specified hosts.
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/git-credential-keepassxc.nix#L55
    # Without hosts, the credential helper applies globally (acceptable).
  };
}
