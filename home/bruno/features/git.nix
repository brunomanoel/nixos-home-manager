{ pkgs, ... }:
{
  home.packages = [
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Bruno Manoel";
        email = "26349861+brunomanoel@users.noreply.github.com";
      };
      pull = {
        rebase = true;
      };
      branch = {
        autosetuprebase = "always";
      };
      init.defaultBranch = "main";
      rerere.enabled = true;
      fetch.prune = true;
    };
    signing.signByDefault = true;
    signing.format = "ssh";
    signing.key = "~/.ssh/github.pub";
    ignores = [
      ".direnv"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
    options = {
      features = "side-by-side line-numbers decorations";
      syntax-theme = "Dracula";
      decorations = {
        commit-decoration-style = "ol";
        hunk-header-decoration-style = "box ul ol";
        hunk-header-style = "file line-number syntax";
        file-decoration-style = "ul";
      };
      interactive = {
        keep-plus-minus-markers = true;
      };
      line-numbers = {
        line-numbers-minus-style = 124;
        line-numbers-plus-style = 28;
      };
      hyperlinks = {
        hyperlinks = true;
        hyperlinks-file-link-format = "vscode://file/{path}:{line}";
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Bruno Manoel";
        email = "26349861+brunomanoel@users.noreply.github.com";
      };
    };
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      git.pagers = [
        {
          pager = "delta --paging=never --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
        }
      ];
    };
  };
}
