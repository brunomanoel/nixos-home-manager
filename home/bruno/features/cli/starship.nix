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
        "\${custom.typescript}"
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
        # style = "bold lavender";
      };
      directory.substitutions = {
        "Documents" = "Documents 󰈙 ";
        "Downloads" = "Downloads  ";
        "Music" = "Music  ";
        "Pictures" = "Pictures  ";
        "workspaces" = "workspaces ";
      };
      hostname = {
        ssh_symbol = " ";
      };
      time = {
        disabled = false;
        style = "bold white";
        format = "[$time]($style)";
      };
      jobs = {
        # symbol = " ";
        symbol = "";
        style = "bold red";
        number_threshold = 1;
        format = "[$symbol$number]($style) ";
      };
      cmd_duration = {
        # style = "bold yellow";
        format = "([$duration]($style))";
      };
      container = {
        symbol = " ";
        style = "bold blue";
        format = "[$symbol\[$name\]]($style) ";
      };
      git_branch = {
        symbol = " ";
        # format = '[\[$symbol$branch(:$remote_branch)\]]($style) '
        # format = '[$symbol$branch(:$remote_branch)]($style) '
      };
      git_commit = {
        disabled = false;
        tag_disabled = false;
        # commit_hash_length = 4
        # tag_symbol = '🔖 '
      };
      git_state = {
        disabled = false;
        # format = '[\($state( $progress_current of $progress_total)\)]($style) '
        # cherry_pick = '[🍒 PICKING](bold red)'
      };
      git_metrics = {
        disabled = false;
        # added_style = 'bold blue'
        format = "(([+$added]($added_style))(/[-$deleted]($deleted_style)))";
      };
      git_status = {
        disabled = false;
        conflicted = "=$count";
        deleted = "✘$count";
        renamed = "»$count";
        stashed =  ''\$$count'';
        untracked = "?$count";
        # up_to_date = "✓";
        # stashed = "📦";
        modified = "!$count";
        # staged = "[++\($count\)](green)";
        staged = "[+\($count\)](bold blue)";
        # deleted = "🗑";
        ahead = "⇡$count";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣$count";
      };
      aws = {
        symbol = "  ";
        disabled = true;
      };
      docker_context = {
        # symbol = "🐳 ";
        symbol = " ";
      };
      golang = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      java = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      lua = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      nix_shell = {
        disabled = false;
        symbol = " ";
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        unknown_msg = "[unknown shell](bold yellow)";
        # format = "[$symbol($name )]($style)";
        format = "via [☃️ $state( \($name\))](bold blue) ";
      };
      nodejs = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      custom.typescript = {
        disabled = false;
        symbol = " ";
        style = "bold blue";
        format = "[$symbol]($style)";
        detect_extensions = ["ts" "tsx"];
        detect_files = ["tsconfig.json" "tsconfig.build.json"];
        description = "Custom module for TypeScript";
      };
      bun = {
        format = "[$symbol($version )]($style)";
      };
      package = {
        symbol = "📦 ";
        # symbol = "󰏗 ";
        disabled = false;
        display_private = true;
      };
      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Windows = "󰍲 ";
      };
      python = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      rust = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      scala = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
      };
      # scan_timeout = 10;

      palette = "dracula";

      # Define Dracula theme
      aws.style = "bold orange";
      # character.error_symbol = "[λ](bold red)";
      # character.success_symbol = "[λ](bold green)";
      cmd_duration.style = "bold yellow";
      directory.style = "bold green";
      hostname.style = "bold purple";
      git_branch.style = "bold pink";
      git_status.style = "bold red";
      username.style_user = "bold cyan";

      # Define Dracula color palette
      palettes.dracula = {
        background = "#282a36";
        current_line = "#44475a";
        foreground = "#f8f8f2";
        comment = "#6272a4";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };

      palettes.catpuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };
    };
  };
}
