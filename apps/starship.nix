{ config, pkgs, lib, ... }:
{
  programs.starship = {
  	enable = true;
  	enableZshIntegration = true;
  	enableBashIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$package"

        "$fill"
        "$cmd_duration $jobs"
        "$nodejs"
        "$bun"
        "$java"
        "$go"
        "$python"
        "$rust"
        "$elixir"
        "$time"
        "$line_break"
        "$container"
        "$character"
      ];
      right_format = lib.concatStrings [
        "[$git_metrics]($style)"
        "[$git_commit]($style)"
        "[$git_state]($style)"
      ];
      fill = {
        symbol = " ";
      };
      directory = {
        truncation_length = 8;
        truncation_symbol = "…/";
        read_only = " 󰌾";
        style = "bold lavender";
      };
      directory.substitutions = {
        "Documents" = "Documents 󰈙 ";
        "Downloads" = "Downloads  ";
        "Music" = "Music  ";
        "Pictures" = "Pictures  ";
      };
      # scan_timeout = 10;
    };
  };
}
