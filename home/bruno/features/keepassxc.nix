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
        MinimizeAfterUnlock = false;
        MinimizeOnCopy = true;
      };

      Security = {
        ClearClipboard = true;
        ClearClipboardTimeout = 10;
        LockDatabaseIdle = false;
        LockDatabaseScreenLock = false;
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
        ConfirmAccessItem = false;
      };

      GUI = {
        ApplicationTheme = "dark";
        ShowTrayIcon = true;
        MinimizeToTray = true;
        MinimizeOnClose = true;
        MinimizeOnStartup = false;
        HidePasswords = true;
        CompactMode = false;
        CheckForUpdates = false; # managed by Nix
      };
    };
  };
}
